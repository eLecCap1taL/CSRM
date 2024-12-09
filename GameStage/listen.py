from http.server import BaseHTTPRequestHandler, HTTPServer
import time

class TimeoutHTTPRequestHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        try:
            # 获取请求长度和数据
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length).decode('utf-8')
            
            # 打印接收到的数据
            print(f"Received POST data: {post_data}")

            # 模拟服务器处理数据（如果需要延迟处理，可以修改 sleep 时间）
            # time.sleep(0.5)  # 可选：模拟一些延迟处理
            
            # 返回 2XX 响应状态码
            self.send_response(200)
            self.send_header("Content-type", "text/plain")
            self.end_headers()
            self.wfile.write(b"Data received successfully")
        except Exception as e:
            # 如果发生错误，确保返回一个响应以避免超时
            print(f"Error processing request: {e}")
            self.send_response(500)
            self.end_headers()
            self.wfile.write(b"Internal Server Error")

# 配置服务器
host = "127.0.0.1"
port = 55599

if __name__ == "__main__":
    server = HTTPServer((host, port), TimeoutHTTPRequestHandler)
    print(f"Server running on {host}:{port}")
    server.serve_forever()
