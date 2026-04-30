import os
import shutil
import pandas as pd
from tqdm import tqdm
# -------- CONFIG --------
SRC_IMG_DIR = "ISIC_2019_Training_Input"
GT_CSV      = "train_gt.csv"
OUT_DIR     = "ISIC_2019_mini_folder"

CLASSES = ["MEL", "NV", "BCC", "AK", "BKL", "DF", "VASC", "SCC"]
# ------------------------
os.makedirs(OUT_DIR, exist_ok=True)
# Create class folders
for cls in CLASSES:
    os.makedirs(os.path.join(OUT_DIR, cls), exist_ok=True)
# Load ground truth
df = pd.read_csv(GT_CSV)
# Convert one-hot → label
df["label"] = df[CLASSES].idxmax(axis=1)

print(f"Processing {len(df)} images...")

missing = 0

for _, row in tqdm(df.iterrows(), total=len(df)):
    img_id = row["image"]
    label  = row["label"]

    src_path = os.path.join(SRC_IMG_DIR, f"{img_id}.jpg")
    dst_path = os.path.join(OUT_DIR, label, f"{img_id}.jpg")

    if os.path.exists(src_path):
        shutil.copy2(src_path, dst_path)
    else:
        missing += 1

print(f"Done. Missing files: {missing}")
