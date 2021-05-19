from flask import Flask, request
import os
from werkzeug.utils import secure_filename
from services import InputToOutputAudio

server_app = Flask(__name__)
services = InputToOutputAudio()

@server_app.route('/translate_voice', methods=['POST'])
def translate_voice():
    audio_file = request.files['audio_file']
    print(type(audio_file))
    audio_filename = secure_filename(audio_file.filename)
    audio_file_path = os.path.join(os.getcwd(), 'audio_data', audio_filename)
    
    audio_file.save(audio_file_path)

    itoa = InputToOutputAudio()
    output_audio = itoa.inputToOutputAudio(audio_data = audio_file_path)
    return 'HTTP 200'
