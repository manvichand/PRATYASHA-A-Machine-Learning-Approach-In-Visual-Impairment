import tensorflow as tf
import os
from data_augumentataion import get_data_augmentation

def load_dataset(train_path, valid_path, test_path, img_shape=(150, 150)):
    """Load and preprocess the dataset from specified directories."""
    
    # Data augmentation for training images
    data_augmentation = get_data_augmentation()

    # Load training images
    training_images = tf.keras.utils.image_dataset_from_directory(
        train_path,
        image_size=img_shape,
        shuffle=True,
        seed=0,
        batch_size=64
    )

    # Apply data augmentation to training images
    train_images = training_images.map(lambda x, y: (data_augmentation(x), y))

    # Load validation images (without augmentation)
    validation_images = tf.keras.utils.image_dataset_from_directory(
        valid_path,
        image_size=img_shape,
        shuffle=False,
        seed=0,
        batch_size=16
    )

    # Rescale validation images
    data_rescale = tf.keras.Sequential([
        tf.keras.layers.Rescaling(1./255)
    ])
    validation_images = validation_images.map(lambda x, y: (data_rescale(x), y))

    # Load test images (without augmentation)
    test_images = tf.keras.utils.image_dataset_from_directory(
        test_path,
        image_size=img_shape,
        shuffle=False,
        seed=0,
        batch_size=32
    )

    return train_images, validation_images, test_images
