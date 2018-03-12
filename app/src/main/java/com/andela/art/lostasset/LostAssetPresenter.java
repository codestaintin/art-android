package com.andela.art.lostasset;


import java.util.ArrayList;

public class LostAssetPresenter {

    LostAssetContract.LostAssetView view;
    LostAssetContract.LostAssetModel model;

    public LostAssetPresenter(LostAssetContract.LostAssetView view, LostAssetContract.LostAssetModel model) {
        this.view = view;
        this.model = model;
    }

    public void getCohorts() {
        ArrayList<String> cohorts = model.fetchCohorts();
        view.showCohorts(cohorts);
    }

    public void getAssets() {
        ArrayList<String> assets = model.fetchAssets();
        view.showAssets(assets);
    }
}
