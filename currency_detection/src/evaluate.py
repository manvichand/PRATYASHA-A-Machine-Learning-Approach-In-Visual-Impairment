import os
import numpy as np
import matplotlib.pyplot as plt
import tensorflow as tf
from data.data_loading import load_data
from data.data_preprocessing import preprocess_data
from model import build_resnet_101
from sklearn.metrics import classification_report, confusion_matrix
import seaborn as sns
import json

# Paths to your datasets
train_image_path = r'currency_detection\currency_dataset\train'
validation_image_path = r'currency_detection\currency_dataset\valid'
test_image_path = r'currency_detection\currency_dataset\test'

# Load data
training_images, validation_images, test_images = load_data(train_image_path, validation_image_path, test_image_path)

# Preprocess data
training_images = preprocess_data(training_images)
validation_images = preprocess_data(validation_images)
test_images = preprocess_data(test_images)  # Preprocess test images as well

# Load the best model
model = build_resnet_101(input_shape=(150, 150, 3), num_classes=len(training_images.class_names))
model.load_weights('best_model.h5')

# Evaluate the model on the test dataset
test_loss, test_accuracy = model.evaluate(test_images)
print(f'Test accuracy: {test_accuracy:.4f}')

# Make predictions on test dataset
y_pred = model.predict(test_images)
y_pred_classes = np.argmax(y_pred, axis=1)

# Get true labels
y_true = test_images.classes  # Assuming test_images have a .classes attribute

# Generate confusion matrix
conf_matrix = confusion_matrix(y_true, y_pred_classes)

# Print classification report
class_report = classification_report(y_true, y_pred_classes, target_names=test_images.class_names)
print(class_report)

# Plot confusion matrix
plt.figure(figsize=(8, 6))
sns.heatmap(conf_matrix, annot=True, fmt='d', cmap='Blues', xticklabels=test_images.class_names, yticklabels=test_images.class_names)
plt.xlabel('Predicted')
plt.ylabel('True')
plt.title('Confusion Matrix')
plt.savefig('confusion_matrix.png', dpi=400)
plt.show()

# Load training history from JSON file
with open('training_history.json', 'r') as f:
    history_list = json.load(f)

# Assuming the best history is the last entry in history_list
best_history = history_list[-1]

# Visualize training and validation accuracy and loss
# Plot training and validation accuracy
plt.figure(figsize=(10, 5))
plt.plot(best_history['accuracy'], label='Training Accuracy')
plt.plot(best_history['val_accuracy'], label='Validation Accuracy')
plt.title('Training vs Validation Accuracy')
plt.xlabel('Epochs')
plt.ylabel('Accuracy')
plt.legend()
plt.savefig('training_validation_accuracy.png', dpi=400)
plt.show()

# Plot training and validation loss
plt.figure(figsize=(10, 5))
plt.plot(best_history['loss'], label='Training Loss')
plt.plot(best_history['val_loss'], label='Validation Loss')
plt.title('Training vs Validation Loss')
plt.xlabel('Epochs')
plt.ylabel('Loss')
plt.legend()
plt.savefig('training_validation_loss.png', dpi=400)
plt.show()
