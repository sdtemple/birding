

# Run the initial filtering of metadata
rule clean:
    input:
        notebook = "scripts/filter_metadata.ipynb",
    output:
        output_file = "metadata/train_metadata_cleaned.csv",
    params:
        params_file = "scripts/preprocessing.json",
    shell:
        "papermill --parameters_file {params.params_file} {input.notebook} {output.output_file}"

# Determine the top N most common species
rule common:
    input:
        notebook = "scripts/common_species.ipynb",
        cleaned = "metadata/train_metadata_cleaned.csv",
    output:
        output_file = "metadata/common_species.txt",
    params:
        params_file = "scripts/preprocessing.json",
    shell:
        "papermill --parameters_file {params.params_file} {input.notebook} {output.output_file}"

# Extract geographically diverse species
rule geography:
    input:
        notebook = "scripts/geography.ipynb",
        cleaned = "metadata/train_metadata_cleaned.csv",
        common = "metadata/common_species.txt",
    output:
        output_file = "metadata/geography.txt",
    params:
        params_file = "scripts/preprocessing.json",
    shell:
        "papermill --parameters_file {params.params_file} {input.notebook} {output.output_file}"

# Extract some species from all orders
rule taxonomy:
    input:
        notebook = "scripts/taxonomy.ipynb",
        cleaned = "metadata/train_metadata_cleaned.csv",
        common = "metadata/common_species.txt",
        geography = "metadata/geography.txt",
    output:
        output_file = "metadata/taxonomy.txt",
    params:
        params_file = "scripts/preprocessing.json",
    shell:
        "papermill --parameters_file {params.params_file} {input.notebook} {output.output_file}"

# Extract data from type column
rule featurizing:
    input:
        notebook = "scripts/featurizing.ipynb",
        cleaned = "metadata/train_metadata_cleaned.csv",
        common = "metadata/common_species.txt",
        geography = "metadata/geography.txt",
        taxonomy = "metadata/taxonomy.txt",
    output:
        output_file = "metadata/train_metadata_featurized.csv",
    params:
        params_file = "scripts/preprocessing.json",
    shell:
        "papermill --parameters_file {params.params_file} {input.notebook} {output.output_file}"

# Unzip the audio files, which can be large
rule unzip_audio:
    input:
        # rename the notebook to the correct name in scripts
        notebook = "scripts/unzip_audio.ipynb",
        featurized = "metadata/train_metadata_featurized.csv",
        common = "metadata/common_species.txt",
        geography = "metadata/geography.txt",
        taxonomy = "metadata/taxonomy.txt",
    output:
        # modify this to have at least one file
        output_file = "train_audio/brnowl/XC154984.ogg",
    params:
        params_file = "scripts/preprocessing.json",
    shell:
        "papermill --parameters_file {params.params_file} {input.notebook} {output.output_file}"

# Do nothing after at least Brown Owl file is unzipped
rule all:
    input:
        "train_audio/brnowl/XC154984.ogg",

