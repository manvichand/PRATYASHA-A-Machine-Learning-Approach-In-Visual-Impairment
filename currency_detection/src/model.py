import tensorflow as tf
from keras import layers, models

def identity_block(input_tensor, kernel_size, filters):
    """A single identity block for ResNet."""
    filters1, filters2, filters3 = filters

    # Shortcut path
    shortcut = input_tensor

    # First convolutional layer
    x = layers.Conv2D(filters1, kernel_size=(1, 1), padding='same')(input_tensor)
    x = layers.BatchNormalization()(x)
    x = layers.Activation('relu')(x)

    # Second convolutional layer
    x = layers.Conv2D(filters2, kernel_size=kernel_size, padding='same')(x)
    x = layers.BatchNormalization()(x)
    x = layers.Activation('relu')(x)

    # Third convolutional layer
    x = layers.Conv2D(filters3, kernel_size=(1, 1), padding='same')(x)
    x = layers.BatchNormalization()(x)

    # Add the shortcut to the output
    x = layers.add([x, shortcut])
    x = layers.Activation('relu')(x)
    
    return x

def convolutional_block(input_tensor, kernel_size, filters, strides=2):
    """A single convolutional block for ResNet."""
    filters1, filters2, filters3 = filters

    # Shortcut path
    shortcut = layers.Conv2D(filters3, kernel_size=(1, 1), strides=strides, padding='same')(input_tensor)
    shortcut = layers.BatchNormalization()(shortcut)

    # First convolutional layer
    x = layers.Conv2D(filters1, kernel_size=(1, 1), strides=strides, padding='same')(input_tensor)
    x = layers.BatchNormalization()(x)
    x = layers.Activation('relu')(x)

    # Second convolutional layer
    x = layers.Conv2D(filters2, kernel_size=kernel_size, padding='same')(x)
    x = layers.BatchNormalization()(x)
    x = layers.Activation('relu')(x)

    # Third convolutional layer
    x = layers.Conv2D(filters3, kernel_size=(1, 1), padding='same')(x)
    x = layers.BatchNormalization()(x)

    # Add the shortcut to the output
    x = layers.add([x, shortcut])
    x = layers.Activation('relu')(x)
    
    return x

def build_resnet_101(input_shape, num_classes):
    """Build the ResNet-101 model."""
    
    # Input layer
    input_tensor = layers.Input(shape=input_shape)

    # Initial Convolution
    x = layers.Conv2D(64, kernel_size=(7, 7), strides=(2, 2), padding='same')(input_tensor)
    x = layers.BatchNormalization()(x)
    x = layers.Activation('relu')(x)
    x = layers.MaxPooling2D(pool_size=(3, 3), strides=(2, 2), padding='same')(x)

    # Define the layers of ResNet-101
    x = convolutional_block(x, 3, [64, 64, 256], strides=1)  # Block 1
    for _ in range(2):
        x = identity_block(x, 3, [64, 64, 256])

    x = convolutional_block(x, 3, [128, 128, 512])  # Block 2
    for _ in range(3):
        x = identity_block(x, 3, [128, 128, 512])

    x = convolutional_block(x, 3, [256, 256, 1024])  # Block 3
    for _ in range(22):
        x = identity_block(x, 3, [256, 256, 1024])

    x = convolutional_block(x, 3, [512, 512, 2048])  # Block 4
    for _ in range(2):
        x = identity_block(x, 3, [512, 512, 2048])

    # Global Average Pooling
    x = layers.GlobalAveragePooling2D()(x)
    
    # Fully connected layer
    x = layers.Dense(num_classes, activation='softmax')(x)

    # Create the model
    model = models.Model(inputs=input_tensor, outputs=x)

    return model
