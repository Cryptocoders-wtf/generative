import { App, computed, watch } from "vue";
import { useI18n } from "vue-i18n";
import { useRoute } from "vue-router";

export const i18nUtils = (app: App) => {
  app.config.globalProperties.localizedUrl = (path: string) => {
    const lang = app.config.globalProperties.$route.params.lang;
    if (lang) {
      return `/${lang}` + path;
    }
    return path;
  };
};

export const useI18nParam = () => {
  const route = useRoute();
  const i18n = useI18n();

  const lang = computed(() => {
    return (route.params.lang as string) || "en";
  });
  watch(lang, () => {
    i18n.locale.value = lang.value;
  });
  i18n.locale.value = lang.value;
};

export const useLocalizedPath = () => {
  const route = useRoute();
  const getLocalizedPath = (path: string) => {
    const lang = (route.params.lang as string) || "en";
    return `/${lang}` + path;
  };
  return {
    getLocalizedPath,
  };
};
