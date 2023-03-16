from flask import Flask, request, render_template
from flask_socketio import SocketIO, emit;
from json import loads
import base64

app = Flask(__name__)
socketio = SocketIO(app)
app.config['SECRET_KEY'] = '!!secret@##1' #change this!
password = "4422" #change this!
data_to_show = ""

def sendMsg(data):
    emit("imgdata", data, json=True, broadcast=True, namespace="")

@app.route('/')
def index():
    return render_template("index.html")

@app.route('/imgdata')
def imgdata():
    if request.args.get('data') and request.args.get('pass') and request.args.get('pass') == password :
        data_to_show = base64.b64decode(request.args.get('data')).decode("utf-8")
        sendMsg(loads(data_to_show))
        return "Sent!"
    else:
        return "Error"

if __name__ == "__main__":
    socketio.run(app, host="0.0.0.0", port=80)
