from flask import Flask, render_template, request

app = Flask(__name__)

import socket
import os

@app.route('/')
def home():
    # Get client IP
    client_ip = request.headers.get('X-Forwarded-For', request.remote_addr)
    # Get ELB IP (simulate as remote_addr or X-Forwarded-For)
    elb_ip = request.headers.get('X-Forwarded-For', request.remote_addr)
    # Get Docker IP (host IP inside container)
    docker_ip = socket.gethostbyname(socket.gethostname())
    # Get Docker container name (from environment variable or hostname)
    docker_name = os.environ.get('HOSTNAME', socket.gethostname())
    return render_template('index.html', client_ip=client_ip, elb_ip=elb_ip, docker_ip=docker_ip, docker_name=docker_name)

@app.route('/order', methods=['GET', 'POST'])
def order():
    name = None
    if request.method == 'POST':
        name = request.form.get('name')
    return render_template('order.html', name=name)

@app.route('/submit', methods=['GET', 'POST'])
def submit():
    name = None
    if request.method == 'POST':
        name = request.form.get('name')
    return render_template('submit.html', name=name)


@app.route('/health')
def health():
    return {'status': 'healthy'}, 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)