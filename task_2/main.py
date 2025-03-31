import sys
import requests
import json

METADATA_URL = "http://169.254.169.254/latest/meta-data"
TOKEN = requests.put("http://169.254.169.254/latest/api/token", headers={"X-aws-ec2-metadata-token-ttl-seconds": "21600"}).text

# Function to recursively fetch metadata
def fetch_aws_metadata(path=""):
    url = f"{METADATA_URL}/{path}".rstrip("/")
    headers = {"X-aws-ec2-metadata-token": TOKEN}

    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()

        if response.status_code != 200:
            print(f"Received status code: {response.status_code}")
            return None
    except requests.exceptions.RequestException as e:
        print(f"Received exception: {e}")
        exit(1)

    data = response.text.strip().split("\n")

    # If it's a single value (not a directory), return the value
    if len(data) == 1 and not data[0].endswith("/"):
        return data[0]

    metadata = {}

    for item in data:
        item_path = f"{path}/{item}".lstrip("/")

        if item.endswith("/"):
            metadata[item[:-1]] = fetch_aws_metadata(item_path)
        else:
            value = requests.get(f"{METADATA_URL}/{item_path}", headers=headers).text
            metadata[item] = value

    return metadata

def main():
    """Main function to handle argument parsing and execution."""
    if len(sys.argv) > 1:
        field = sys.argv[1]
        metadata = fetch_aws_metadata(field)  # Reuse fetch_metadata for single keys
        if metadata:
          print(json.dumps(metadata, indent=2))
    else:
        metadata = fetch_aws_metadata()
        print(json.dumps(metadata, indent=2))

if __name__ == "__main__":
    main()
