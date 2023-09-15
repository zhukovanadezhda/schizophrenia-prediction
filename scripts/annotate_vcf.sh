#!/bin/bash

VCFS_PATH="/mnt/c/Users/nadia/OneDrive/Desktop/data"
CLASSIFYCNV_PATH="/mnt/c/Users/nadia/IPNP/ClassifyCNV"

# Check if CLASSIFYCNV_PATH is valid
if [ ! -d "$CLASSIFYCNV_PATH" ]; then
  echo "CLASSIFYCNV_PATH is not a valid directory."
  exit 1
fi

# Check if VCFS_PATH is valid
if [ ! -d "$VCFS_PATH" ]; then
  echo "VCFS_PATH is not a valid directory."
  exit 1
fi

# Count the number of .vcf.gz files in the directory
vcf_files_count=$(find "$VCFS_PATH" -maxdepth 1 -type f \( -name "*.vcf.gz" -o -name "*.vcf" \) | wc -l)
echo "Found $vcf_files_count .vcf.gz and .vcf files in the directory."

processed_files=0

for vcf_gz_file in ${VCFS_PATH}/*.vcf.gz; do
  # Check if there are any .vcf.gz files in the directory
  if [ -e "$vcf_gz_file" ]; then
    gzip -d "$vcf_gz_file"
  fi
done

for vcf_file in ${VCFS_PATH}/*.vcf; do
  # Check if there are any .vcf files in the directory
  if [ -e "$vcf_file" ]; then
    echo "Processing $(basename "$vcf_file")."
    ((processed_files++))
  fi

    # Filter variants to leave only FILTER=PASS
    filtered_vcf="./data/filtered_$(basename "$vcf_file")"
    bcftools view -i 'FILTER="PASS"' -O z -o "${filtered_vcf}" "${vcf_file}"

    # Convert the filtered VCF to ClassifyCNV input format
    bed_file="./data/$(basename "$vcf_file").bed"
    python3 scripts/vcf2bed.py "${filtered_vcf}" "${bed_file}"

    # Annotate with ClassifyCNV
    result_dir=$(python3 "${CLASSIFYCNV_PATH}/ClassifyCNV.py" --infile "${bed_file}" --GenomeBuild hg38 2>&1 | grep -oP 'Results saved to \K.*')

    if [ -n "$result_dir" ]; then
      mv "${result_dir}/Scoresheet.txt" ./annotations/annotated_$(basename "$vcf_file")
    else
      echo "Error: No results found."
    fi


    echo "Processed $processed_files of $vcf_files_count files."
done

echo "Annotation completed for all VCF files."