import process from "node:process";

let url;
if (process.env.FLY_APP_NAME) {
  // https://fly.io/docs/machines/runtime-environment/#environment-variables
  url = "https://giacomodebidda-indiekit.fly.dev";
  // I created a CNAME record on Cloudflare DNS, yet this doesn't work.
  // url = "https://indiekit.giacomodebidda.com";
} else {
  url = `http://localhost:${process.env.PORT}`;
}

// A publication is any website to which you are publishing content to via Indiekit.
// https://getindiekit.com/concepts#publication
// With this, no images show up in the Indiekit UI because I have yet something
// to implement on my website.
const publication_me = "https://www.giacomodebidda.com/";
// With this, images show up in the Indiekit UI because they are served from a
// Cloudflare R2 bucket which is publicly exposed on this subdomain.
// const publication_me = "https://content.giacomodebidda.com/";

// const categories = `${publication_me}/tags/index.json`;
// Should I create an index.json like this one?
// https://github.com/aciccarello/ciccarello-indiekit/blob/3381efe087a99b4ceaed44af2bf8f80ca79e52a8/indiekit.config.js#L61C5-L61C52
// here is how to do it:
// https://github.com/aciccarello/ciccarello.me/blob/main/posts/tags/index.json.11ty.js
// https://www.giacomodebidda.com/tags/index.html

const cloudflare_account_id = "43f9884041661b778e95a26992850715";

const config = {
  application: {
    // If using Indieauth:
    // authorizationEndpoint: "https://indieauth.com/auth",
    // tokenEndpoint: "https://tokens.indieauth.com/token",
    locale: "en",
    name: "Indiekit",
    themeColor: "#C80815",
    timeZone: "Europe/Rome",
    url,
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

console.info(
  `Indiekit server runs at ${config.application.url} and publishes to ${config.publication.me}`,
);

export default config;
