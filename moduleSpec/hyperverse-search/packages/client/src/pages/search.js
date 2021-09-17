import DappLib from "@decentology/dappstarter-dapplib";
import DOM from "../components/dom";
import "../components/action-card.js";
import "../components/action-button.js";
import "../components/text-widget.js";
import "../components/number-widget.js";
import "../components/account-widget.js";
import "../components/upload-widget.js";
import { unsafeHTML } from "lit-html/directives/unsafe-html";
import { LitElement, html, customElement, property } from "lit-element";

@customElement("search-page")
export default class DappSearchPage extends LitElement {
  @property()
  results;

  createRenderRoot() {
    return this;
  }

  constructor(args) {
    super(args);
    this.results =
      localStorage.getItem("search-page-results") ?? JSON.stringify([]);
    this.results = JSON.parse(this.results);
  }

  render() {
    let content = html`<div class="flex flex-col items-center ">
      <h1>Search results :)</h1>
      ${this.results.length <= 0
        ? html`<p>No results :(</p>`
        : this.results.map(
            (result) =>
              html` <li
                class="flex flex-col items-start justify-start py-2 cursor-pointer w-9/12 sm:w-7/12 md:w-9/12 lg:w-7/12  hover:bg-blue-200 dark:text-gray-400 bg-white dark:bg-gray-800 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-700 font-normal pr-18 sm:pr-24 pl-10 text-sm border-gray-300 dark:border-gray-700 rounded border shadow text-left"
              >
                <span class="font-bold text-green-700">${result.name}</span>
                <span class="text-gray-500">${result.description}</span>
              </li>`
          )}
    </div> `;
    return content;
  }
}
