# PDJSKit

PDJSKit is a Swift package that extracts JavaScript function names from schedule definitions and checks which functions are available in a `JSContext`.

## Features

- Extract unique function names from schedule definition strings
- Filter existing JavaScript functions loaded in a `JSContext`

## Usage

Import `PDJSKit` in your Swift project and use `extractFunctionNames` on a schedule definition string. Then call `filterAvailableFunctions` with a `JSContext` to get the list of callable functions.

## Apps Using

<p float="left">
    <a href="https://apps.apple.com/jp/app/tweetpd/id1671411031"><img src="https://i.imgur.com/AC6eGdx.png" height="65"></a>
</p>

## License

This project is released under the MIT License. See [LICENSE](LICENSE) for details.
