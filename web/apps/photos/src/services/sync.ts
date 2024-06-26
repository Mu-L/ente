import { faceWorker } from "@/new/photos/services/face";
import { fetchAndSaveFeatureFlagsIfNeeded } from "@/new/photos/services/feature-flags";
import { clipService } from "services/clip-service";
import { syncCLIPEmbeddings } from "services/embeddingService";
import { syncEntities } from "services/entityService";
import { syncMapEnabled } from "services/userService";
import { isFaceIndexingEnabled } from "./face/indexer";

/**
 * Perform a soft "refresh" by making various API calls to fetch state from
 * remote, using it to update our local state, and triggering periodic jobs that
 * depend on the local state.
 */
export const sync = async () => {
    // TODO: This is called after we've synced the local files DBs with remote.
    // That code belongs here, but currently that state is persisted in the top
    // level gallery React component.

    await syncEntities();
    await syncMapEnabled();
    fetchAndSaveFeatureFlagsIfNeeded();
    const electron = globalThis.electron;
    if (electron) {
        await syncCLIPEmbeddings();
        if (isFaceIndexingEnabled()) await (await faceWorker()).sync();
    }
    if (clipService.isPlatformSupported()) {
        void clipService.scheduleImageEmbeddingExtraction();
    }
};
