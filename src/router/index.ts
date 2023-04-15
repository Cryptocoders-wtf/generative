import { createRouter, createWebHistory, RouteRecordRaw } from "vue-router";
import Layout from "@/components/Layout.vue";
import Blank from "@/components/Blank.vue";
import NotFound from "@/components/NotFound.vue";

import Home from "@/views/Home.vue";

import Create from "@/views/Create.vue";
import Item from "@/views/Item.vue";

import Items from "@/views/Items.vue";
import SvgTest from "@/views/SVGTest.vue";

const routeChildren: Array<RouteRecordRaw> = [
  {
    path: "",
    component: Create,
  },
  {
    path: "svg",
    component: Create,
  },
  {
    path: "item/:token_id",
    name: "item",
    component: Item,
  },
  // for debug
  {
    path: "svgtest",
    component: SvgTest,
  },
  {
    path: "items",
    component: Items,
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
