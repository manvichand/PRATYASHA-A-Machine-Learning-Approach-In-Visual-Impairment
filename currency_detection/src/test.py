import os
import numpy as np
import matplotlib.pyplot as plt
import tensorflow as tf
from data.data_loading import load_data
from data.data_preprocessing import preprocess_data
from model import build_resnet_101
from keras.preprocessing import image

# Path to your test images
test_images_path = r'testing images'

# Load the trained model
model = build_resnet_101(input_shape=(150, 150, 3), num_classes=len(os.listdir(test_images_path)))
model.load_weights('best_model.h5')

# Function to load and preprocess images from the specified directory
def load_and_preprocess_images(image_directory):
    images = []
    filenames = []
    
    for img_filename in os.listdir(image_directory):
        img_path = os.path.join(image_directory, img_filename)
        
        # Load image
        img = image.load_img(img_path, target_size=(150, 150))
        img_array = image.img_to_array(img)
        img_array = np.expand_dims(img_array, axis=0)  # Add batch dimension
        
        images.append(img_array)
        filenames.append(img_filename)
        
    return np.vstack(images), filenames  # Stack all images into a single numpy array

# Load and preprocess test images
test_images, filenames = load_and_preprocess_images(test_images_path)

# Make predictions on test images
predictions = model.predict(test_images)
predicted_classes = np.argmax(predictions, axis=1)

# Load class names if needed (modify according to your data structure)
class_names = os.listdir(test_images_path)

# Print predictions
for filename, predicted_class in zip(filenames, predicted_classes):
    print(f"Image: {filename}, Predicted Class: {class_names[predicted_class]}")

# Visualize predictions (optional)
def visualize_predictions(test_images, predicted_classes, filenames):
    plt.figure(figsize=(15, 10))
    
    for i in range(len(filenames)):
        plt.subplot(5, 5, i + 1)  # Adjust the grid size according to your needs
        plt.imshow(test_images[i].astype('uint8'))
        plt.title(f"Predicted: {class_names[predicted_classes[i]]}")
        plt.axis('off')
    
    plt.tight_layout()
    plt.savefig('test_predictions.png', dpi=400)
    plt.show()

# Call the visualization function
visualize_predictions(test_images, predicted_classes, filenames)
