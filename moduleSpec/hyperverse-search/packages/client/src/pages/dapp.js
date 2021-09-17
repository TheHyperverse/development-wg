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
import MiniSearch from "minisearch";

const FAKE_REGISTRY = [
  {
    id: 1,
    name: "Subscription",
    description: "add simple subscription capabilities ",
  },
  {
    id: 2,
    name: "KYC",
    description: "add oracle driven KYC capabilities via synapse",
  },
  {
    id: 3,
    name: "Ballot",
    description: "add simple voting capabilities",
  },
  {
    id: 4,
    name: "Auction",
    description: "add simple auction capabilities",
  },
];

@customElement("dapp-page")
export default class DappPage extends LitElement {
  @property()
  get;
  @property()
  post;
  @property()
  title;
  @property()
  category;
  @property()
  description;
  @property()
  miniSearch;
  @property()
  results;

  createRenderRoot() {
    return this;
  }

  constructor(args) {
    super(args);

    this.results = [];

    // Setup search instance
    this.miniSearch = new MiniSearch({
      fields: ["name", "description"],
      storeFields: ["name", "description"],
    });

    // Load fake data for search
    this.miniSearch.addAll(FAKE_REGISTRY);

    // Remove any old search results
    localStorage.setItem("search-page-results", JSON.stringify([]));
  }

  getPages() {
    return [
      {
        name: "search",
        title: "Search",
        route: "/search",
      },
    ];
  }

  handleClick = (e) => {
    e.preventDefault();
    localStorage.setItem("dappstarter-page", e.target.dataset.link);
    this.setPageLoader(e.target.dataset.link);
  };

  setPageLoader(name) {
    let pageLoader = document.getElementById("page-loader");
    pageLoader.load(name, this.getPages());
    this.requestUpdate();
  }

  handleSearch = (e) => {
    const search = this.miniSearch.search(e.target.value);
    // normalize search results
    this.results = search.map(({ name, description }) => {
      return { name, description };
    });
    // store in local storage for search page to use
    localStorage.setItem("search-page-results", JSON.stringify(this.results));
  };

  render() {
    let content = html`
      <div
        style="height:80vh;"
        class="container flex flex-col justify-center m-auto"
      >
        <div class="row fadeIn mt-3 p-2 block text-center ">
          <h2 class="text-5xl ">🚀 Into the Hyperverse 🚀</h2>

          <div class="flex flex-row justify-center mt-8 ">
            <div class="relative">
              <div
                class="absolute text-gray-600 dark:text-gray-400 flex items-center pl-3 h-full"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="icon icon-tabler icon-tabler-search"
                  width="16"
                  height="16"
                  viewBox="0 0 24 24"
                  stroke-width="1.5"
                  stroke="currentColor"
                  fill="none"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                >
                  <path stroke="none" d="M0 0h24v24H0z" />
                  <circle cx="10" cy="10" r="7" />
                  <line x1="21" y1="21" x2="15" y2="15" />
                </svg>
              </div>
              <input
                id="search"
                @input=${this.handleSearch}
                class="text-gray-600 dark:text-gray-400 bg-white dark:bg-gray-800 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-700 font-normal pr-20 sm:pr-32 h-12 flex items-center pl-10 text-sm border-gray-300 dark:border-gray-700 rounded border shadow"
                placeholder="Search the Hyperverse"
              />
            </div>
            <button
              @click=${this.handleClick}
              data-link="search"
              type="button"
              class="inline-flex items-center px-6 py-2 ml-2 border border-transparent text-base font-normal rounded-md shadow-sm text-white bg-blue-900 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
            >
              Search
            </button>
          </div>
          <div class="mt-2 flex flex-col items-center">
            ${this.results.map(
              (data) =>
                html`<li
                  class="flex flex-col items-start justify-start py-2 cursor-pointer w-9/12 sm:w-7/12 md:w-9/12 lg:w-7/12  hover:bg-blue-200 dark:text-gray-400 bg-white dark:bg-gray-800 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-700 font-normal pr-18 sm:pr-24 pl-10 text-sm border-gray-300 dark:border-gray-700 rounded border shadow text-left"
                >
                  <span class="font-bold text-green-700">${data.name}</span>
                  <span class="text-gray-500">${data.description}</span>
                </li>`
            )}
          </div>
        </div>
      </div>
    `;
    return content;
  }
}
