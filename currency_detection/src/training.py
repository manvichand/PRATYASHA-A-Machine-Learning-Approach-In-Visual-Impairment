import os
import tensorflow as tf
from data.data_loading import load_data
from data.data_preprocessing import preprocess_data
from data.data_augumentataion import augment_data
from model import build_resnet_101
from keras.callbacks import EarlyStopping, ModelCheckpoint
from sklearn.model_selection import ParameterGrid
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

# Data Augmentation
training_images = augment_data(training_images)

# Performing hyperparameter tuning
param_grid = {
    'learning_rate': [1e-3, 1e-4],
    'batch_size': [32, 64],
    'epochs': [10, 20]
}

# Perform hyperparameter tuning
best_val_loss = float('inf')
best_model = None
history_list = []  # To store history for each parameter set

for params in ParameterGrid(param_grid):
    print(f"Training with parameters: {params}")

    model = build_resnet_101(input_shape=(150, 150, 3), num_classes=len(training_images.class_names))
    model.compile(optimizer=tf.keras.optimizers.Adam(learning_rate=params['learning_rate']),
                  loss='sparse_categorical_crossentropy',
                  metrics=['accuracy'])

    # Fit the model
    history = model.fit(training_images,
                        validation_data=validation_images,
                        batch_size=params['batch_size'],
                        epochs=params['epochs'],
                        callbacks=[
                            EarlyStopping(patience=3, restore_best_weights=True),
                            ModelCheckpoint('best_model.h5', save_best_only=True)
                        ])
    
    # Save history for this parameter set
    history_list.append(history.history)

    # Evaluate validation loss
    val_loss = history.history['val_loss'][-1]
    if val_loss < best_val_loss:
        best_val_loss = val_loss
        best_model = model

# After training, evaluate the model on the test dataset
test_loss, test_accuracy = best_model.evaluate(test_images)
print(f'Test accuracy: {test_accuracy:.4f}')

# Save the training history to a JSON file
with open('training_history.json', 'w') as f:
    json.dump(history_list, f)
