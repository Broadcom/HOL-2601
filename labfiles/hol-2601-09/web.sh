cat <<EOF | sudo tee /home/holuser/web-frontend.py

import socketserver

# server.py
import http.server

PORT = 80
PAYLOAD_SIZE = 100 * 1024  # 100 KB

class LargePayloadHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        payload = b"A" * PAYLOAD_SIZE
        self.send_response(200)
        self.send_header("Content-type", "text/plain")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

if __name__ == "__main__":
    with socketserver.TCPServer(("", PORT), LargePayloadHandler) as httpd:
        print(f"Serving on all interfaces at port {PORT}")
        httpd.serve_forever()
EOF

cat <<EOF | sudo tee /home/holuser/web-user.py

import time
import requests

URL = "http://10.1.0.19:80"

def access_page():
    try:
        response = requests.get(URL)
        print(f"Accessed {URL} - Status Code: {response.status_code}")
    except Exception as e:
        print(f"Error accessing {URL}: {e}")

if __name__ == "__main__":
    while True:
        access_page()
        time.sleep(20)

EOF

cat <<EOF | sudo tee /home/holuser/db-user.py
import time
import random
import string
import socket

HOST = '192.168.200.3'
PORT = 1433

def random_string(length):
    return ''.join(random.choices(string.ascii_letters + string.digits, k=length))

def main():
    while True:
        with socket.create_connection((HOST, PORT)) as s:
            s.recv(1024)  # Welcome message

            # Generate enough data for at least 100KB
            num_rows = 100
            value_size = 1024  # 1KB per value
            total_sent = 0

            # Insert many rows
            for i in range(num_rows):
                key = f"table{i}"
                value = random_string(value_size)
                cmd = f"INSERT INTO {key} VALUES ({value})\n"
                s.sendall(cmd.encode())
                s.recv(1024)
                total_sent += len(cmd)

            # Select all rows
            for i in range(num_rows):
                key = f"table{i}"
                cmd = f"SELECT * FROM {key}\n"
                s.sendall(cmd.encode())
                resp = s.recv(2048)
                total_sent += len(cmd) + len(resp)

            # Ensure at least 100KB transferred
            print(f"Transferred {total_sent/1024:.2f} KB this cycle.")

            # Quit
            s.sendall(b"QUIT\n")
            s.recv(1024)

        time.sleep(10)
if __name__ == "__main__":
    main()
EOF


cat <<EOF | sudo tee /etc/systemd/system/db-user.service
[Unit]
Description=DB-User service
After=network.target

[Service]
User=holuser
WorkingDirectory=/home/holuser
ExecStart=python3 /home/holuser/db-user.py

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable db-user.service
sudo systemctl start db-user.service

cat <<EOF | sudo tee /etc/systemd/system/web-user.service
[Unit]
Description=Web-User service
After=network.target

[Service]
User=holuser
WorkingDirectory=/home/holuser
ExecStart=python3 /home/holuser/web-user.py

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable web-user.service
sudo systemctl start web-user.service