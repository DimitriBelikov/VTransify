# from ibm_watson import SpeechToTextV1
# from ibm_cloud_sdk_core.authenticators import IAMAuthenticator
import os
from sys import exc_info
import speech_recognition as sr
import googletrans as gt
import gtts
from random import randint
from pydub import AudioSegment
from pathlib import Path

# sttapikey = 'wW82XoUPgI4tey3TfmY4LKiEeib_iqcJ5FwFt54PyTS_'
# stturl = 'https://api.us-east.speech-to-text.watson.cloud.ibm.com/instances/e4d9d9ef-9aa9-4f68-a9bb-5ce2f38bf147'
audio_dir = os.path.join(os.getcwd(), 'audio_data')
AudioSegment.converter = os.path.join(os.getcwd(), r'Lib\site-packages\ffmpeg\bin\ffmpeg.exe')

class InputToOutputAudio:
    def __init__(self):
        self.__language_codes = {'en-US':'en', 'hi-IN': 'hi', 'ml-IN': 'ml', 'ta-IN':'ta', 'te-IN':'te'}
    # def authenticator(self):
    #     sttauthenticator = IAMAuthenticator(sttapikey)
    #     stt = SpeechToTextV1(authenticator=sttauthenticator)
    #     stt.set_service_url(stturl)
    #     return stt

    def __convertAudioFile(self, audio_path):
        try:
            audio_filename = audio_path[audio_path.rindex('\\')+1:audio_path.rindex('.')]+'.wav'
            audio_path = Path(audio_path)
            print('<------------------------- MP3 to WAV ------------------->\nAudio Path: '+ str(audio_path))

            output_path = Path(os.path.join(audio_dir, audio_filename))
            print('Output Path: ' + str(output_path))

            audio = AudioSegment.from_file(audio_path)
            m = audio.export(output_path, format='wav')
            os.remove(audio_path)
            print('Result: '+ str(m), '\n<------------------------- Process End ---------------------------->')

        except:
            print("Audio File Conversion Error: "+ exc_info()[0])
            output_path = None
            
        return output_path

    def __inputAudioToText(self, audio_path, src_lang):
        audio_recognizer, audio = sr.Recognizer(), None
        with open(audio_path, 'rb') as file:
            with sr.AudioFile(file) as source:
                audio = audio_recognizer.record(source)
            audio_text = audio_recognizer.recognize_google(audio, language=src_lang)
        print('Recognized Text : ', audio_text)
        return audio_text
    
    def __translateText(self, input_text, src_language, to_language):
        translator = gt.Translator()
        translated_text = translator.translate(input_text, src=self.__language_codes[src_language], dest=self.__language_codes[to_language])
        print('Translation Details: ', translated_text)
        return translated_text.text
    
    def __translatedTexttoOutputAudio(self, translated_text, to_language):
        output_audio = gtts.gTTS(translated_text, lang=self.__language_codes[to_language])
        return output_audio
    
    def inputToOutputAudio(self, audio_path, from_lang='en-US', to_lang='hi-IN'):
        audio_path = self.__convertAudioFile(audio_path)
        if audio_path != None:
            audio_path = str(audio_path)
            recog_audio_text = self.__inputAudioToText(audio_path, from_lang)

            if recog_audio_text != None:
                translated_text = self.__translateText(recog_audio_text, from_lang, to_lang)
                output_audio = self.__translatedTexttoOutputAudio(translated_text, to_lang)

                output_filename = audio_path[audio_path.rindex('\\')+1:]
                
                output_audio_path, response = os.path.join(os.getcwd(), 'output_data', output_filename), 200
                output_audio.save(output_audio_path)
                print('<============================== TRANSLATION END ==================================>\n')

                return {'response': response, 'output_filepath': output_audio_path, 'translated_text': translated_text}
            else:
                return None
        else:
            return None

class RandomTextGenerator:

    def generate_random_text(self):
        filename_length = randint(10,15)
        filename = ''
        for x in range(1, filename_length+1):
            random_2, random_3 = randint(1,10), 99
            
            if random_2 < 6:
                random_3 = str(randint(1,9))
            else:
                random_3 = chr(randint(65,90))

            filename += random_3
        return filename