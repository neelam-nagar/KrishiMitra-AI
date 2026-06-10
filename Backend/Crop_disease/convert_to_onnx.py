import torch
import torchvision.models as models
from torch import nn

model = models.efficientnet_b0(weights=None)
model.classifier[1] = nn.Linear(model.classifier[1].in_features, 12)

checkpoint = torch.load('model/rajasthan_crop_model.pth', map_location='cpu')
model.load_state_dict(checkpoint['model_state_dict'])
model.eval()

dummy_input = torch.randn(1, 3, 224, 224)
torch.onnx.export(
    model, dummy_input, "model/crop_disease.onnx",
    input_names=['input'], output_names=['output'], opset_version=11
)
print("✅ crop_disease.onnx ready!")
