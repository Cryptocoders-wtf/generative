import { ref, computed, Ref } from "vue";

import { Drawing } from "@/models/point";

export const useUndoStack = (drawing: Ref<Drawing>) => {
  const undoStack = ref<Drawing[]>([]);
  const undoIndex = ref<number>(0);

  const recordState = () => {
    const array = undoStack.value.filter((state, index) => {
      return index < undoIndex.value;
    });
    array.push(drawing.value);
    undoStack.value = array;
    undoIndex.value = undoStack.value.length;
  };

  const isRedoable = computed(() => {
    return undoIndex.value + 1 < undoStack.value.length;
  });

  const isUndoable = computed(() => {
    return undoIndex.value > 0;
  });

  const _undo = () => {
    console.log("undo", isUndoable.value);
    if (!isUndoable.value) {
      return null;
    }
    if (!isRedoable.value) {
      recordState();
      undoIndex.value -= 1;
    }
    drawing.value = undoStack.value[undoIndex.value - 1];
    undoIndex.value -= 1;
  };
  const _redo = () => {
    if (!isRedoable.value) {
      return null;
    }
    drawing.value = undoStack.value[undoIndex.value + 1];
    undoIndex.value += 1;
  };

  return {
    recordState,
    isRedoable,
    isUndoable,
    _undo,
    _redo,
  };
};
