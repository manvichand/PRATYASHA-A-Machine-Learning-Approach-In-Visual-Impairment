# from flask import Flask, request, jsonify
# from tensorflow.keras.models import load_model
# from tensorflow.keras.preprocessing import image
# import numpy as np
# from io import BytesIO

# app = Flask(__name__)

# # Loading model from device
# model = load_model(r"C:\Users\exact\OneDrive\Desktop\nepali_currency_recognition_tensorflow\Nepali-Cash-Detection-Recognition-main (1)\Nepali-Cash-Detection-Recognition-main\currency_detection_final_model.h5")

# # Classes of Nepali currency
# classes = ["50", "5", "500", "100", "10", "1000", "20"]

# @app.route('/predict', methods=['POST', 'GET'])
# def predict():
#     if request.method == 'POST':
#         try:
#             file = request.files['file']

#             img = image.load_img(BytesIO(file.read()), target_size=(150, 150))
#             img_array = image.img_to_array(img)
#             img_array = np.expand_dims(img_array, axis=0)
#             img_array /= 255.0

#             predictions = model.predict(img_array)

#             predicted_class = np.argmax(predictions)
            
#             predicted_currency = classes[predicted_class]

#             result = {'predicted_currency': predicted_currency}
#             return jsonify(result)
#         except Exception as e:
#             return jsonify({'error': str(e)})
#     else:
#         return jsonify({'message': 'Send a POST request to this endpoint for predictions.'})

# if __name__ == '__main__':
#     app.run(host='0.0.0.0', port=5000, debug=True)



# #At postman
#     #post request
#    # http://localhost:5000/predict
#     #key = file


from flask import Flask, request, jsonify
from keras.models import load_model
from keras.preprocessing import image
import numpy as np
from io import BytesIO
from flask_cors import CORS

app = Flask(__name__)
CORS(app)


# model = load_model(r"C:\Users\exact\OneDrive\Desktop\nepali_currency_recognition_tensorflow\Nepali-Cash-Detection-Recognition-main (1)\Nepali-Cash-Detection-Recognition-main\currency_detection_final_model.h5")

# model = load_model(r"C:\Users\exact\Downloads\currency_detection_final_model_inceptionV3_new_dataset_feb_17.h5")
model = load_model(r"C:\Users\exact\Downloads\currency_detection_final_model_resnet101_new_dataset_feb_18_1pm.h5")

classes = ["50", "5", "500", "100", "10", "1000", "20"]

@app.route('/predict', methods=['POST'])
def predict():
    try:
        if 'file' not in request.files:
            return jsonify({'error': 'No file part'})

        file = request.files['file']
        img = image.load_img(BytesIO(file.read()), target_size=(224, 224))
        img_array = image.img_to_array(img)
        img_array = np.expand_dims(img_array, axis=0)
        img_array /= 255.0

        predictions = model.predict(img_array)

        predicted_class = np.argmax(predictions)
        predicted_currency = classes[predicted_class]

        result = {'predicted_currency': predicted_currency}
        return jsonify(result)
    except Exception as e:
        return jsonify({'error': f'Error predicting currency: {str(e)}'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)


