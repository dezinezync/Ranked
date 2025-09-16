/**
 * To regenerate the list included in the app,
 * Open https://affiliate.itunes.apple.com/resources/documentation/linking-to-the-itunes-music-store/#CountryCodes in a browser
 * Scroll to the table with the list of countries, their respective country codes and store front IDs.
 * Select the <tbody> element of the table in the Browser's Developer tools
 * Run the following code in the console.
 * As on 14 Oct, 2018, this script has been tested and known to work as expected.
 */
const list = {};

// these  are the country codes
const items = [...$0.querySelectorAll("td:not(:nth-child(2n+1))")].map(i => i.textContent);

// the format is: 0:Name, 1:Storefront ID, 2:Name, 3:Storefront ID
const values = [...$0.querySelectorAll("td:nth-child(2n+1)")].map(i => i.textContent);

items.forEach((i, idx) => {
    list[i] = {
        name: values[(idx * 2)],
        storeFrontID: values[(idx * 2) + 1]
    };
});

copy(JSON.stringify(list));
