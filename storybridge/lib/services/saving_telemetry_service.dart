enum SaveState { notSaved, saving, saved, errored }

SaveState saveState = SaveState.saving;

void indicateNotSaved() {
  if (saveState != SaveState.errored) saveState = SaveState.notSaved;
}

void indicateSaving() {
  saveState = SaveState.saving;
}

void indicateSaved() {
  if (saveState == SaveState.saving) saveState = SaveState.saved;
}

void indicateErrored() {
  saveState = SaveState.errored;
}
