import { createApp } from "vue";
import { createI18n } from "vue-i18n";
import App from "./App.vue";
import "./index.css";
import router from "./router";
import store from "./store";

import i18nConf from "./i18n/index";
import { i18nUtils } from "./i18n/utils";

import VueQrcode from '@chenfengyuan/vue-qrcode';

const i18n = createI18n(i18nConf);

const app = createApp(App);
app.use(store);
app.use(router);
app.use(i18n);
app.use(i18nUtils);

app.component(VueQrcode.name, VueQrcode);

app.mount("#app");
