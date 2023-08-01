import * as wasm from "assemblying-pixels";

let name = window.prompt("Qual o seu nome?", "Rust");
let text;

if (name === null) {
    text = "=/";
} else {
    text = name;
}

wasm.greet(text);
