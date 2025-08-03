import os
import boto3
import time
import logging
from flask import Flask, request, jsonify
from botocore.exceptions import ClientError
from functools import wraps

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# Initialize S3 client with retry configuration
s3_client = boto3.client(
    's3',
    config=boto3.session.Config(
        retries={
            'max_attempts': 3,
            'mode': 'standard'
        }
    )
)
S3_BUCKET = os.environ.get('S3_BUCKET_NAME')

# Request validation decorator


def validate_json(*expected_args):
    def decorator(f):
        @wraps(f)
        def wrapper(*args, **kwargs):
            if not request.is_json:
                return jsonify({"error": "Content-Type must be application/json"}), 415

            data = request.get_json()
            missing = [arg for arg in expected_args if arg not in data]
            if missing:
                return jsonify({
                    "error": f"Missing required parameters: {', '.join(missing)}",
                    "required_parameters": expected_args
                }), 400

            return f(*args, **kwargs)
        return wrapper
    return decorator


# Retry decorator for S3 operations
def retry_s3_operation(max_retries=3, delay=1, backoff=2):
    def decorator(f):
        @wraps(f)
        def wrapper(*args, **kwargs):
            retries = 0
            current_delay = delay

            while retries < max_retries:
                try:
                    return f(*args, **kwargs)
                except ClientError as e:
                    retries += 1
                    if retries == max_retries:
                        logger.error(
                            f"S3 operation failed after {max_retries} attempts: {str(e)}"
                        )
                        raise

                    logger.warning(
                        f"S3 operation failed (attempt {retries}/{max_retries}). "
                        f"Retrying in {current_delay} seconds..."
                    )
                    time.sleep(current_delay)
                    current_delay *= backoff

            raise Exception("Max retries exceeded")
        return wrapper
    return decorator


def check_health():
    """Check the health of the service.
    
    Returns:
        tuple: A tuple of (dict, int) containing the status and HTTP status code
    """
    try:
        # Add additional health checks here (e.g., database connection)
        return {
            "status": "healthy",
            "service": "mcp-server",
            "version": "1.0.0"
        }, 200
    except Exception as e:
        logger.error(f"Health check failed: {str(e)}")
        return {
            "status": "unhealthy",
            "error": str(e)
        }, 500

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint with basic service status"""
    try:
        response, status_code = check_health()
        return jsonify(response), status_code
    except Exception as e:
        logger.error(f"Health check failed: {str(e)}")
        return jsonify({
            "status": "unhealthy",
            "error": str(e)
        }), 500


@app.route("/summarize", methods=["POST"])
@validate_json("file_key")
@retry_s3_operation(max_retries=3, delay=1, backoff=2)
def summarize_text():
    """
    Endpoint to summarize text from an S3 file
    Expects JSON payload: {"file_key": "path/to/file.txt"}
    """
    try:
        data = request.get_json()
        file_key = data['file_key']  # Already validated by decorator

        logger.info(f"Processing summarization request for file: {file_key}")

        # Get file from S3 with retry logic
        try:
            response = s3_client.get_object(Bucket=S3_BUCKET, Key=file_key)
            text = response['Body'].read().decode('utf-8')

            # In a real implementation, you would call Amazon Bedrock here
            # For this PoC, we'll just return a simple summary
            summary = f"Summary for {file_key}: " f"{text[:100]}{'...' if len(text) > 100 else ''}"

            logger.info(f"Successfully processed file: {file_key}")
            return jsonify({
                "status": "success",
                "summary": summary,
                "file_key": file_key
            }), 200

        except s3_client.exceptions.NoSuchKey:
            logger.error(f"File not found in S3: {file_key}")
            return jsonify({
                "error": f"File not found: {file_key}",
                "status": "error"
            }), 404

        except ClientError as e:
            error_code = e.response.get('Error', {}).get('Code', 'UnknownError')
            logger.error(f"S3 error ({error_code}) for file {file_key}: {str(e)}")
            raise

    except Exception as e:
        logger.error(f"Unexpected error in summarize_text: {str(e)}")
        return jsonify({
            "status": "error",
            "error": "Failed to process request"
        }), 500


# Error handlers
@app.errorhandler(404)
def not_found_error(error):
    return jsonify({"error": "Not found"}), 404


@app.errorhandler(500)
def internal_error(error):
    return jsonify({"error": "Internal server error"}), 500


if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    app.run(host='0.0.0.0', port=port, debug=False)
