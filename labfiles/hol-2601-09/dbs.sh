cat <<EOF | sudo tee /home/holuser/db-server.py

import socket
import threading
import random
import string

HOST = '0.0.0.0'
PORT = 1433

# Simple in-memory "database"
database = {}

def handle_client(conn, addr):
    with conn:
        conn.sendall(b"Welcome to FakeSQL 1.0\n")
        while True:
            data = conn.recv(1024)
            if not data:
                break
            command = data.decode().strip()
            if command.upper().startswith("SELECT"):
                key = command.partition("FROM")[2].strip()
                value = database.get(key, "NULL")
                conn.sendall(f"{value}\n".encode())
            elif command.upper().startswith("INSERT"):
                try:
                    _, rest = command.split("INTO", 1)
                    table, values = rest.strip().split("VALUES", 1)
                    key = table.strip()
                    value = values.strip().strip("()")
                    database[key] = value
                    conn.sendall(b"OK\n")
                except Exception:
                    conn.sendall(b"ERROR\n")
            elif command.upper() == "RANDOM":
                # For testing: insert random data
                key = ''.join(random.choices(string.ascii_lowercase, k=5))
                value = ''.join(random.choices(string.ascii_letters + string.digits, k=10))
                database[key] = value
                conn.sendall(f"Inserted {key}: {value}\n".encode())
            elif command.upper() == "QUIT":
                conn.sendall(b"BYE\n")
                break
            else:
                conn.sendall(b"Unknown command\n")

def main():
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind((HOST, PORT))
        s.listen()
        print(f"FakeSQL server listening on {HOST}:{PORT}")
        while True:
            conn, addr = s.accept()
            print(f"Connected by {addr}")
            threading.Thread(target=handle_client, args=(conn, addr), daemon=True).start()

if __name__ == "__main__":
        main()

EOF

sudo chmod +x /home/holuser/db-server.py

cat <<EOF | sudo tee /etc/systemd/system/db-server.service
[Unit]
Description=DB-Server service
After=network.target

[Service]
User=root
Group=root
WorkingDirectory=/home/holuser
ExecStart=python3 /home/holuser/db-server.py

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable db-server.service
sudo systemctl start db-server.service