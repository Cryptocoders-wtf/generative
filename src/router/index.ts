import { createRouter, createWebHistory, RouteRecordRaw } from "vue-router";
import Layout from "../components/Layout.vue";
import Blank from "../components/Blank.vue";
import NotFound from "../components/NotFound.vue";

import Splatter from "../views/Splatter.vue";

const routeChildren: Array<RouteRecordRaw> = [
  {
    path: "",
    component: Splatter,
  },
];

const routes: Array<RouteRecordRaw> = [
  {
    path: "/",
    component: Layout,
    children: [
      {
        path: "/:lang(en|ja)",
        component: Blank,
        children: routeChildren,
      },
      {
        path: "",
        component: Blank,
        children: routeChildren,
      },
    ],
  },
  {
    path: "/:page(.*)",
    name: "NotFoundPage",
    component: Layout,
    children: [
      {
        path: "",
        component: NotFound,
      },
    ],
  },
];

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes,
});

export default router;
