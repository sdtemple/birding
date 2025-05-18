
#  SchMichigan Model

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This document provides a brief overview of creating models for the Kaggle BirdCLEF competitions, which focus on identifying bird species from audio recordings. There can be multiple birds calling in a time slice!

Competition URLs:
- [2025](https://www.kaggle.com/competitions/birdclef-2025)
- [2024](https://www.kaggle.com/competitions/birdclef-2024)
- [2023](https://www.kaggle.com/competitions/birdclef-2023)
- [2022](https://www.kaggle.com/competitions/birdclef-2022)
- [2021](https://www.kaggle.com/competitions/birdclef-2021)

<img src="the_state_of_michigan_with_a_bird.jpeg" align="center" width="300px"/>

(The icon is courtesy of the Meta AI Llama model.)

## Repository Guide

1. Modify `settings.yaml` for different file locations.
2. Modify `preprocessing.json` for different filtering and array manipulation options.
3. Run `snakemake -c1 -n --configfile settings.yaml` to preprocess data into tensors.
    - Use first letters (copy from `alphabet.txt`) in `settings.yaml` to split preprocessing.
    - Then, use `scripts/concatenate.ipynb`.
4. Fit models. An examle notebook is `cnn_model.ipynb`.
- Use `scripts/recurrent_format.ipynb` to consider RNNs.

In general, use `papermill` to run notebooks in `scripts/`. See `Snakefile` for examples.

I would like to consider the following:
- Explore RNNs and LSTMs with convolutional layers
- Augment label classes with call types and biological sex
- Mix up audio based on geography and time of day

[One CRNN implementation in torch](https://github.com/meijieru/crnn.pytorch)
[One GRCNN implementation in torch](https://github.com/Jianf-Wang/GRCNN)

Here, UM personnel can access our pre-processed data. We also have running notes on models that we have tried.

[Colab space](https://drive.google.com/drive/folders/1qJLyViIYkpYbLYqh5rqvK6GntFjuvukk?usp=sharing)

## Installation

```
mamba env create -f environment.yml
```

## Key Steps:
1. **Data Preprocessing**:
    - Convert audio files into mel-spectrograms.
    - Call zeros with heuristic algorithm of zero crossing rate 

2. **Model Selection**:
    - Use architectures like single point CNNs and RNNs with convolutional layers.
    - Consider transformer-based models for sequential audio data.

3. **Training**:
    - Pre-train models on 2022 and 2023 data.
    - Employ techniques like learning rate scheduling and early stopping.

4. **Evaluation**:
    - Use metrics like Mean Average Precision (MAP) or F1-score.
    - Validate on a diverse subset of the dataset to ensure robustness.

5. **Submission**:
    - Format predictions as required by the competition rules.
    - Test the model on unseen data before submission.

## Tools and Libraries:
- librosa for audio
- numpy, torch, sklearn, jax, tensorflow
    - Focus on torch for NNs