

from flask import Flask, request, jsonify
from PIL import Image, ImageOps, ImageFilter
import pytesseract
import cv2
import json
import requests
from io import BytesIO

app = Flask(__name__)
pytesseract.pytesseract.tesseract_cmd = 'C:\\Program Files\\Tesseract-OCR\\tesseract.exe'

def process_image(image):
    # Convert the image to grayscale
    grayscale_image = ImageOps.grayscale(image)
    # enhanced_image = grayscale_image.filter(ImageFilter.EDGE_ENHANCE)

    # Perform OCR on the grayscale image

    text = pytesseract.image_to_string(grayscale_image)

    # Detect words and apply bounding boxes
    boxes = pytesseract.image_to_data(grayscale_image, output_type=pytesseract.Output.DICT)
    bounding_boxes = []
    for count, b in enumerate(boxes['text']):
        x, y, width, height = boxes['left'][count], boxes['top'][count], boxes['width'][count], boxes['height'][count]
        bounding_boxes.append({'text': b, 'x': x, 'y': y, 'width': width, 'height': height})

    return text, bounding_boxes

@app.route('/ocr', methods=['POST'])
def ocr():
    try:
        
        if 'image' not in request.files:
            return jsonify({'error': 'No file part'})

        image_file = request.files['image']
        image = Image.open(image_file)

        
        text, bounding_boxes = process_image(image)

        
        json_data = {'text': text, 'bounding_boxes': bounding_boxes}
        with open('bounding_boxes.json', 'w') as json_file:
            json.dump(json_data, json_file)

        
        api_url = 'http://192.168.176.222:6000/ocr'
        api_payload = {'words': [word['text'] for word in bounding_boxes]}
        response = requests.post(api_url, json=api_payload)

        if response.status_code == 200:
            print("Words successfully sent to the API.")
        else:
            print(f"Error sending words to the API. Status code: {response.status_code}")

        return jsonify({'text': text})
    except Exception as e:
        return jsonify({'error': f'Error predicting text: {str(e)}'})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=6000, debug=True)
