<template>
  <div class="mx-auto max-w-3xl p-2 text-left">
    <h1 class="text-xl font-bold mt-2 mb-2">Fully On-Chain Generative Art</h1>
    <p class="mb-2">This is a website for developers who are interested in <b>on-chain generative art</b>,
      which means you write Solidity code to generate art in SVG format.</p>
    <p class="mb-2">Unlike images stored on HTTP servers or IPFS, 
      on-chain generative arts are truly decentralized and composable and can generate revenue autonomously
      (we will release a <b>decentralized autonomous marketplace</b> of generative arts soon).</p>
    <p class="mb-2">Because this is such a new field, I am going to guide you to get there step by step.</p>
    <p class="mb-2">First of all, please learn how to write JavaScript/TypeScript code to generate art in SVG format,
      which helps you to understand what it takes to generate art in SVG format.
      It also helps you to refine your algorithm quickly (it takes a long time to do it in Solidity).</p>
    <p class="mb-2">Please run the following commands in your terminal.</p>
    <pre>
      git clone git@github.com:Cryptocoders-wtf/generative.git
      cd generative
      yarn install
      yarn run serve
    </pre>
    <p class="mb-2">Then, open "localhost:8080" in your browser. You'll see the clone of this website.</p>
    <p class="mb-2">Read src/views/Splatter.vue, and learn how it works (please go to the Splatter page to see its output). 
      It generates a series of <i>control points</i>, generates an SVG path from them, and generates an SVG image.</p>
      <p class="mb-2">Once you understand it, duplicate Splatter.vue file, and party on it.
        You need to modify src/router/index.ts and src/components/Header.vue appropriately to add your vue to the menu.
      </p>
    <p class="mb-2">I am going to describe how to port your JavaScript/TypeScript code to Solidity later.</p>
    <p class="mb-2">Meanwhile, please join <a href="https://discord.gg/4JGURQujXK" class="underline">our discord</a>, and feel free to ask any questions either in English or Japanese.</p>
  </div>
</template>

<script lang="ts">
    import { defineComponent } from "vue";
    export default defineComponent({
      setup() {
        return {
        };
      },
    });
</script>