package com.andela.art.lostasset;

import java.util.ArrayList;

/**
 * Created by Jeffkungu on 12/03/2018.
 */

public interface LostAssetContract {

    interface LostAssetModel {
        ArrayList<String> fetchCohorts();
        ArrayList<String> fetchAssets();
    }

    interface LostAssetView {
        void showCohorts(ArrayList<String> cohorts);
        void showAssets(ArrayList<String> assets);
    }
}
