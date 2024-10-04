# data/data_loading.py
import tensorflow as tf
import os
import matplotlib.pyplot as plt

def load_dataset(data_path, img_shape, batch_size, shuffle=True):
    """
    Load the dataset from the specified directory.

    Parameters:
        data_path (str): The path to the dataset directory.
        img_shape (int): The target image size (img_shape, img_shape).
        batch_size (int): The number of samples per gradient update.
        shuffle (bool): Whether to shuffle the data.

    Returns:
        tf.data.Dataset: A TensorFlow dataset object.
    """
    dataset = tf.keras.utils.image_dataset_from_directory(
        data_path,
        image_size=(img_shape, img_shape),
        shuffle=shuffle,
        seed=0,
        batch_size=batch_size
    )
    return dataset

def display_sample_images(data_path, img_shape):
    """
    Display sample images from each class in the training dataset.

    Parameters:
        data_path (str): The path to the training dataset directory.
        img_shape (int): The target image size (img_shape, img_shape).
    """
    class_directories = [os.path.join(data_path, d) for d in os.listdir(data_path) 
                         if os.path.isdir(os.path.join(data_path, d))]

    num_classes = len(class_directories)
    num_cols = 4 
    num_rows = (num_classes + num_cols - 1) // num_cols  

    fig, axes = plt.subplots(num_rows, num_cols, figsize=(15, 15))
    fig.suptitle("Sample Images from Each Class in Training Dataset", fontsize=16)

    for i, class_dir in enumerate(class_directories):
        ax = axes[i // num_cols, i % num_cols]
        
        image_files = [f for f in os.listdir(class_dir) if f.lower().endswith(('.png', '.jpg', '.jpeg', '.gif', '.bmp'))]
        
        if image_files:
            img_path = os.path.join(class_dir, image_files[0])
            img = tf.keras.preprocessing.image.load_img(img_path, target_size=(img_shape, img_shape))
            ax.imshow(img)
            ax.set_title(os.path.basename(class_dir))
            ax.axis('off')  
        else:
            ax.axis('off')

    for i in range(num_classes, num_rows * num_cols):
        fig.delaxes(axes.flatten()[i])

    plt.tight_layout()
    plt.show()

def load_all_datasets(train_path, val_path, test_path, img_shape, batch_size):
    """
    Load training, validation, and test datasets.

    Parameters:
        train_path (str): The path to the training dataset directory.
        val_path (str): The path to the validation dataset directory.
        test_path (str): The path to the test dataset directory.
        img_shape (int): The target image size (img_shape, img_shape).
        batch_size (int): The number of samples per gradient update.

    Returns:
        tuple: A tuple containing training, validation, and test datasets.
    """
    train_dataset = load_dataset(train_path, img_shape, batch_size, shuffle=True)
    val_dataset = load_dataset(val_path, img_shape, batch_size, shuffle=False)
    test_dataset = load_dataset(test_path, img_shape, batch_size, shuffle=False)

    return train_dataset, val_dataset, test_dataset
