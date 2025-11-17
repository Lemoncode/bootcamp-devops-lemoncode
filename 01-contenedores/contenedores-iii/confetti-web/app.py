from flask import Flask, render_template

app = Flask(__name__)

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/health')
def health():
    return {'status': 'healthy', 'message': '🎉 Confetti app is running!'}, 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3000, debug=True)