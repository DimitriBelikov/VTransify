from flask import Flask, request, send_from_directory
import os
from werkzeug.utils import secure_filename
from services import InputToOutputAudio, RandomTextGenerator
from json import dumps
from sys import exc_info

server_app = Flask(__name__)
services = InputToOutputAudio()

server_app.config["OUTPUT_AUDIO"] = os.getcwd() + '\output_data'

@server_app.route('/translate-voice', methods=['POST'])
def translate_voice():
    print(request.files)
    try:
        audio_file = request.files['audio_file']
        from_lang, to_lang = request.form['from_lang'], request.form['to_lang']

        audio_filename = RandomTextGenerator().generate_random_text() + audio_file.filename[audio_file.filename.rindex('.'):]
        audio_filepath = os.path.join(os.getcwd(), 'audio_data', audio_filename)

        print('\nAudio : '+ audio_filename)
        audio_file.save(audio_filepath)

        itoa = InputToOutputAudio()
        service_response = itoa.inputToOutputAudio(audio_path = audio_filepath, from_lang=from_lang, to_lang=to_lang)

        if service_response != None:
            response, output_audio, translated_text = service_response['response'], service_response['output_filepath'], service_response['translated_text']
            html_responsedata = {'Response': response, 'redirect_path': audio_filename[:audio_filename.rindex('.')], 'translated_text': translated_text}
        else:
            response = 500
            error_message = 'AudioConversionError/TranslationError: The file was either not converted properly or Audio was not able to be recognized'
            html_responsedata = {'Response': response, 'ErrorMessage': error_message}
    except:
        response = 500
        error_message = 'Server Processing Error: File was not uploaded successfully'
        html_responsedata = {'Response': response, 'ErrorMessage': error_message}
        print(exc_info()[0])

    html_response = dumps(html_responsedata)
    return html_response

@server_app.route('/output-audio/<audiofile>', methods=['GET'])
def getaudio(audiofile):
    for files in os.listdir(os.path.join(os.getcwd(),'output_data')):
        if files[:files.index('.')] == audiofile:
            audio_filename = files
            audio_directory = os.path.join(server_app.root_path, server_app.config['OUTPUT_AUDIO'])
            print(audio_directory)

            return send_from_directory(directory=audio_directory, path=audio_filename, as_attachment=True)
    return '<h1> Error 500 - File Not Found </h1>'