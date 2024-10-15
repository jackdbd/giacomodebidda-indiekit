import process from "node:process";

const config = {
  application: {
    name: "My IndieWeb Server",
    timeZone: "Europe/Rome",
  },
  plugins: [
    "@indiekit/preset-eleventy",
    "@indiekit/store-github",
    "@indiekit/syndicator-mastodon",
  ],
  publication: {
    me: "https://giacomodebidda.com/",
  },
  "@indiekit/store-github": {
    user: "jackdbd",
    repo: "indiekit-content",
    branch: "main",
    token: process.env.GITHUB_TOKEN,
  },
  "@indiekit/syndicator-mastodon": {
    checked: true,
    url: "https://fosstodon.org",
    user: "jackdbd",
  },
};

console.log(`Indiekit server will publish to ${config.publication.me}`);

export default config;
