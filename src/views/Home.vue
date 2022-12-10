<template>
  <div class="mx-auto max-w-3xl p-2 text-left">
    <h1 class="mt-2 mb-2 text-xl font-bold">Fully On-chain Generative Art</h1>
    <p class="mb-2">
      This is a website for developers who are interested in
      <b>fully on-chain generative art</b>, which means
      <u>you write Solidity code to dynamically generate art in SVG</u>.
    </p>
    <p class="mb-2">
      Unlike images stored on HTTP servers or IPFS, on-chain generative arts are
      truly decentralized and composable (i.e., re-use image from other smart
      contracts). It can even generate revenue autonomously (we will launch a
      <b>decentralized autonomous marketplace</b> for generative arts soon).
    </p>
    <p class="mb-2">
      Traditional on-chain NFTs, such as Nouns, had very poor graphics (see
      below), and this project was born to solve this problem.
    </p>
    <img class="mb-4" src="https://i.imgur.com/R9aTx5N.png" />
    <p class="mb-2">
      Because this is such a new field, we are going to guide you to get there
      step by step.
    </p>
    <h1 class="mt-2 mb-2 text-xl font-bold">Architecture</h1>
    <p class="mb-2">
      Here is the rough architecture diagram of a sample generative art NFT
      collection, SplatterToken.
    </p>
    <img class="mb-4" src="@/assets/architecture_gen.png" />
    <p class="mb-2">
      SplatterToken implements tokenURI by calling generateSVGPart() of
      MultiplexProvider. MultiplexProvider implements it by calling
      generateSVGPart() of SplatterProvider multiple times to create an art.
      SplatterProvider implements it by generating a series of control points
      and turning them into a SVG path by calling pathFromPoints() of SVGHelper.
    </p>
    <h1 class="mt-2 mb-2 text-xl font-bold">TypeScript/Javascript Prototype</h1>
    <p class="mb-2">
      First of all, please learn how to write JavaScript/TypeScript code to
      generate art in SVG format, which will make it easy for you to develop
      Solidity-based generative art later. It also helps you to refine your
      algorithm quickly (it takes a long time to do it in Solidity).
    </p>
    <p class="mb-2">Please run the following commands in your terminal.</p>
    <pre
      class="mb-2 rounded-md border border-gray-600 bg-gray-200 bg-opacity-60"
    >
      git clone git@github.com:Cryptocoders-wtf/generative.git
      cd generative
      yarn install
      yarn run serve</pre
    >
    <p class="mb-2">
      Then, open "localhost:8080" in your browser. You'll see the clone of this
      website.
    </p>
    <p class="mb-2">
      Read <code class="bg-gray-200">src/views/Sample.vue</code>, and learn how
      it works (please go to the Sample page to see its output). It generates a
      series of <i>control points</i>, generates an SVG path from them, and
      generates an SVG image.
    </p>
    <p class="mb-2">
      Once you understand it, duplicate Splatter.vue file, and party on it. You
      need to modify <code class="bg-gray-200">src/router/index.ts</code> and
      <code class="bg-gray-200">src/components/Header.vue</code> appropriately
      to add your vue to the menu.
    </p>
    <h1 class="mt-2 mb-2 text-xl font-bold">Graphics Library</h1>
    <p>
      In order to make it easy to develop generative art in Solidity, 
      we have created an open source library, 
      <a class="underline" href="https://www.npmjs.com/package/fully-on-chain.sol">fully-on-chain.sol</a>,
      which allows developers to generative code like this.
      <pre class="mt-2 text-xs">
SVG.rect(256, 256, 512, 512)
  .fill("yellow");
  .stroke("blue", 10)
  .transform("rotate(30 512 512)");
      </pre>
      <img src="https://i.imgur.com/MLEUGD5.png" />
    </p>
    <h1 class="mt-2 mb-2 text-xl font-bold">Porting it to Solidity</h1>
    <p class="mb-2">
      The Soidity version of Splatter is avaiable at
      <code class="bg-gray-200"
        >contract/contracts/providers/SplatterProvider.sol</code
      >. Please compare it to TypeScript version. Although there are some
      differences because of languages, they are build with the same algorithm
      and similar libraries.
    </p>
    <p class="mb-2">
      Please notice that the Solidity version generates art deterministically
      based on the given assetId. This is why some internal functions takes
      Randomizer.seed as the first parameter and returns the updated one, which
      creates a pseudo state variable (or a closure) in read-only methods.
    </p>
    <p class="mb-2">
      The Solidity verison also pre-allocate memory (<code class="bg-gray-200"
        >points</code
      >) instead of dynamically push elements into the array, which is also
      necessary to keep those methods read-only.
    </p>
    <p class="mb-2">
      Please join
      <a href="https://discord.gg/4JGURQujXK" class="underline">our discord</a>,
      and feel free to ask any questions either in English or Japanese.
    </p>
    <References />
  </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import References from "@/components/References.vue";
export default defineComponent({
  components: {
    References,
  },
  setup() {
    console.log("*** env", process.env.VUE_APP_ALCHEMY_API_KEY);
    return {};
  },
});
</script>
