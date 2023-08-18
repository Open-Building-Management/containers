try:
    import tflite_runtime.interpreter as tflite
except Exception as e:
    print(f'error {e}')
else:
    print("tensorflow lite successfully imported")
