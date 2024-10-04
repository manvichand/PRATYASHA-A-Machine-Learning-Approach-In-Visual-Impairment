import tensorflow as tf
from keras import layers, Sequential

def get_data_augmentation():
    """Create a data augmentation sequential model."""
    data_augmentation = Sequential([
        layers.Rescaling(1./255),        # Rescale pixel values to [0, 1]
        layers.RandomRotation(30),       # Randomly rotate images by 30 degrees
        layers.RandomFlip("horizontal"),  # Randomly flip images horizontally
        layers.RandomZoom(0.5)           # Randomly zoom images
    ])
    return data_augmentation
