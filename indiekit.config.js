import process from "node:process";

const cloudflare_account_id = "43f9884041661b778e95a26992850715";

const publication_me = "https://www.giacomodebidda.com/";
// const categories = `${publication_me}/tags/index.json`;
// Should I create an index.json like this one?
// https://github.com/aciccarello/ciccarello-indiekit/blob/3381efe087a99b4ceaed44af2bf8f80ca79e52a8/indiekit.config.js#L61C5-L61C52
// here is how to do it:
// https://github.com/aciccarello/ciccarello.me/blob/main/posts/tags/index.json.11ty.js
// https://www.giacomodebidda.com/tags/index.html

const config = {
  application: {
    // If using Indieauth:
    // authorizationEndpoint: "https://indieauth.com/auth",
    // tokenEndpoint: "https://tokens.indieauth.com/token",
    locale: "en",
    name: "Indiekit",
    themeColor: "#C80815",
    timeZone: "Europe/Rome",
    // url: "https://indiekit.giacomodebidda.com",
  },
  plugins: [
    "@indiekit/preset-eleventy",
    "@indiekit/store-github",
    "@indiekit/store-s3",
    "@indiekit/syndicator-mastodon",
  ],
  publication: {
    me: publication_me,
    mediaStore: "@indiekit/store-s3",
    store: "@indiekit/store-github",
  },
  "@indiekit/store-github": {
    user: "jackdbd",
    repo: "giacomodebidda-content",
    branch: "main",
    token: process.env.GITHUB_TOKEN,
  },
  "@indiekit/store-s3": {
    accessKey: process.env.S3_ACCESS_KEY,
    secretKey: process.env.S3_SECRET_KEY,
    region: "auto",
    endpoint: `https://${cloudflare_account_id}.r2.cloudflarestorage.com`,
    bucket: "giacomodebidda-content",
  },
  "@indiekit/syndicator-mastodon": {
    checked: true,
    url: "https://fosstodon.org",
    user: "jackdbd",
  },
};

console.log(`Indiekit server will publish to ${config.publication.me}`);

export default config;
