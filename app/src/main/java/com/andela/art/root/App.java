package com.andela.art.root;

import android.app.Application;

import com.andela.art.login.LoginModule;

/**
 * Created by Mugiwara_Munyi on 28/02/2018.
 */

public class App extends Application {

    private ApplicationComponent component;

    @Override
    public void onCreate() {
        super.onCreate();
        component = DaggerApplicationComponent.builder()
                .applicationModule(new ApplicationModule(this))
                .loginModule(new LoginModule())
                .build();

    }

    public ApplicationComponent getComponent() {
        return component;
    }
}
