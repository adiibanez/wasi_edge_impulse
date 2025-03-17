#include <cstdint>
#include <cstring>
#include "edge-impulse-sdk/classifier/ei_run_classifier.h"
#include "tflite-model/tflite_learn_7_compiled.h"
#include "model-parameters/model_metadata.h"

// Global signal buffer for continuous inference
static float *signal_buffer = nullptr;
static size_t signal_buffer_size = 0;

extern "C" {
    // Callback function to get data from the signal buffer
    int get_signal_data(size_t offset, size_t length, float *out_ptr) {
        if (offset + length > signal_buffer_size) return -1;
        memcpy(out_ptr, signal_buffer + offset, length * sizeof(float));
        return 0;
    }

    // Get model parameters as JSON string
    const char* get_model_parameters_json() {
        static char params[512];
        snprintf(params, sizeof(params),
            "{"
            "\"input_features\": %d,"
            "\"frequency\": %.1f,"
            "\"frame_length\": %d,"
            "\"label_count\": %d,"
            "\"has_anomaly\": %d,"
            "\"slice_size\": %d,"
            "\"slice_overlap\": %d"
            "}",
            EI_CLASSIFIER_NN_INPUT_FRAME_SIZE,
            EI_CLASSIFIER_FREQUENCY,
            EI_CLASSIFIER_RAW_SAMPLE_COUNT,
            EI_CLASSIFIER_LABEL_COUNT,
            EI_CLASSIFIER_HAS_ANOMALY,
            EI_CLASSIFIER_SLICE_SIZE,
            EI_CLASSIFIER_SLICES_PER_MODEL_WINDOW
        );
        return params;
    }

    // Run inference on a single frame of data
    float* run_model_inference(float* input_data, size_t input_size) {
        static float output[EI_CLASSIFIER_LABEL_COUNT + 1];  // +1 for anomaly score if present
        
        signal_buffer = input_data;
        signal_buffer_size = input_size;

        signal_t signal;
        signal.total_length = input_size;
        signal.get_data = &get_signal_data;

        ei_impulse_result_t result = { 0 };

        // Run inference
        EI_IMPULSE_ERROR res = run_classifier(&signal, &result, false);
        
        if (res != 0) {
            // Return empty array on error
            memset(output, 0, sizeof(output));
            return output;
        }

        // Copy classification results
        for (size_t ix = 0; ix < EI_CLASSIFIER_LABEL_COUNT; ix++) {
            output[ix] = result.classification[ix].value;
        }

        // Add anomaly score if present
        #if EI_CLASSIFIER_HAS_ANOMALY == 1
        output[EI_CLASSIFIER_LABEL_COUNT] = result.anomaly;
        #endif

        return output;
    }

    // Get model labels as comma-separated string
    const char* get_labels() {
        static char labels[512];
        char* ptr = labels;
        
        for (size_t ix = 0; ix < EI_CLASSIFIER_LABEL_COUNT; ix++) {
            if (ix > 0) {
                *ptr++ = ',';
            }
            strcpy(ptr, ei_classifier_inferencing_categories[ix]);
            ptr += strlen(ei_classifier_inferencing_categories[ix]);
        }
        
        return labels;
    }

}
