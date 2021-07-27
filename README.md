![CI](https://github.com/design-ops/stylable-swiftUI/workflows/CI/badge.svg?branch=master&event=push)

# SwiftUIStylable

An attempt to make SwiftUI components stylable by an external type and reusable across apps, based on the principles of Atomic Design (https://bradfrost.com/blog/post/atomic-web-design/).

### Goals

- Create a library of SwiftUI components which can be reused across apps, and can be styled without modification.

- Library of components can be distributed as a Cocoapod (or Carthage, or \<gulp> a Swift Package)

- As little intrusion as possible, and ideomatic SwiftUI code wherever possible

### Nice to haves

- Individual styles can be either hand-typed or generated from a Sketch file

- Compatible with the current format we are working with (section/element/identifier) but extendable to other design systems

- Changing styles in the stylist should update the view

- Testable as much as possible

- Avoid global singletons

## Approach

Create a Stylist object, and pass into the main SwiftUI object as an environmentObject.

Configure the Stylist object by passing in identifiers and a method to modify any views matching that identifier.

Add a view modifier method (`.style(<identifier>)`) which won't actually use a ViewModifier, but will inject a `Stylist` view which wraps the View being styled (i.e. allow the 'atom' concept from Atomic Design).

Add a View `StylistGroup` which will namespace all subsequence views' identifiers (i.e. allow section/element concept from Atomic Design).

The `Styled` view type will apply the correct styling to the view it's wrapping, but will be generic so we can pass it around in the Stylist. Type-erasure will feature heavily here, and I'm sorry for how some of the code looks.

Make the Stylist an ObservableObject so changes to the list of styles will trigger a view redraw.

### Why not a ViewModifier?

Turns out that inside a view modifier you don't have access to the original view you're modifying, you just get `some View`. This is an issue if you want to use any of the methods to style a `Text` instance.

## Our design system

We followed a variant of Atomic Design, choosing to have 3 levels: section / element / atom.

- **atom** - These will styles for native SwiftUI elements i.e. `Text`, `Image`.

- **element** - These are custom components we will create out of atoms i.e. `SearchBar`

- **section** - These will be sections of the app i.e. `client`, `product`.

This means that the style for an atom can be defined in terms of itself, the element it's inside, and the section of the app it is within.

The components we create in code will be at the Element level (SwiftUI has already created the Atoms for us). It's up to the individual apps to place them in sections (or not, their choice).

### Matching identifiers

Identifiers behave similar to css rules. i.e. the identifier `"title"` will match with `"title"` (obviously), but will also match `"section/title"`, `"section/element/title"` etc. `"title"` can be considered to be `"*/*/title"` for matching.

The `Stylist` uses this to decide which style to apply to a view. For example if the Stylist had styles for the identifiers "title", "section/element/title" and "element/title", it would apply the best match it could for each view passed in.

| Known styles -> | "title" | "element/title" | section/element/title |
|---|---|---|---|
| Element to match |  |  |  |
| "title"  | ✔ |  |  |
| "element/title"  |   | ✔ |  |
| "section/element/title" |  |  | ✔ |
| "othersection/title" | ✔ |  |  |

## Usage

# Creating a sharable component

E.g. a view to display a Client in a list. This will match the symbol in our Sketch file called "clientlistitem".

```swift

struct ClientListItemView: View {

  let client: Client

  var body: some View {
    StyledGroup("clientlistitem") {
      HStack {
        Text(client.name).style("heading")
        Text(client.email).style("body")
        ForEach(client.tags) { tag in
          Text(tag).style("tag")
        }
      }
    }
  }
}
```

### Creating the Stylist

In your Scene Delegate, create the root view and give it an environmentObject.

```swift

let view = ClientListView()
            .environmentObject(self.stylist)

```

and, obvs, we'll need to actually create the Stylist.

```swift

private let stylist: Stylist = {
  let stylist = Stylist()

  // Style for any body text
  stylist.addStyle(identifier: "*/*/body") { 
    $0.font(.body)
  }

  // Style for body text when it's in a clientlist
  stylist.addStyle(identifier: "*/clientlistitem/body") { 
    $0.font(.body).background(Color.red)
  }

  return stylist
}()

```

### SwiftUI Previews

To make previews of you views work in Xcode you'll need to provide a stylist environment object there as well.

This is a Good Thing, beacuse you can play around with styles there too.

```swift
struct ClientListItemView_Previews: PreviewProvider {

    /// Some clients to test various layouts
    static private let clients = [
        Client(name: "Max Power", email: "max.power@example.com", tags: [ "EIP", "Big Spender" ]),
        Client(name: "Mr Smith", email: "smith@example.com", tags: [ "Prospect", "EIP" ]),
        Client(name: "Boris Angus Smythe", email: "", tags: []),
    ]

    /// The views to preview
    static var previews: some View {
        ForEach(ClientListItemView_Previews.clients, id: \.self) {
            ClientListItemView(section: "client", client: $0)
        }
        .environmentObject(previewStylist)
        .previewLayout(.fixed(width: 300, height: 70))
    }

    /// The stylist to style the previews with
    static let previewStylist: Stylist = {
        let stylist = Stylist()

        stylist.addStyle(identifier: "body") {
            $0.font(.body)
        }

        stylist.addStyle(identifier: "tag") {
            $0.font(.body).background(Color.red)
        }

        return stylist
    }()
}
```

## Not duplicating style identifiers

One issue with a stylable view is that you have to type identifiers in both the view's implementation and in the stylist when you add styles. That's error prone, so here are some ways around it:

1. Create constants for the style identifiers and just use that constant everywhere.

```swift

public struct ClientListItemView: View {
  ...
  public static let headingStyleIdentifier: StylistIdentifier = "clientlistitem/heading"
  ...
}
```

Pro:

* simple, small amount of code

Cons:

* Still need the stylist code to be aware of the identifiers

2. Create a `StyleContainer`.

A StyleContainer is a collection of styles which can be applied to a stylist as a single object. You can use this to hide the implementation details of applying a style, e.g.

```swift
public struct ClientListItemViewStyle: StyleContainer {
    
  public let styles: [Stylist.Style]

  init(headingFont: Font, bodyFont: Font) {
    self.styles = [
      Stylist.Style("clientlistitemview/heading") { $0.font(font) }
      Stylist.Style("clientlistitemview/body") { $0.font(bodyFont) }
      Stylist.Style("clientlistitemview/tag") { $0.font(bodyFont) }
    ]
  }
}
```

You then use this when you are adding styles to your `Stylist`, like this:

```swift

stylist.addStyles([
  ClientListItemViewStyle(font: Font("Roboto-Bold", pointSize: 20),
                          bodyFont: Font("Roboto-Regular", pointSize: 14))
])

```

Pros:

* If the internal implementation of the view changes, the external interface of the style container can remain the same - that's great for backwards compatibility.
* Better type safety when creating the styles

Cons:

* More code

#### How does this work?

The `addStyles(_:)` method actually adds an array of StyleContainer, not Styles. It works with both because Style conforms to StyleContainer - it's a collection of styles which only contains one style.

## Images

There is a component called `StylableImage` which is given a `StylistIdentifier` instead of a hardcoded image path - this then uses it's location in the app to determine which image asset to load. It's a drop-in replacement for `Image` (technically, it's wrapping `Image` under the hood).

i.e.

```swift
    StylableGroup("client") {
      ...
      StylableGroup("searchbar") {
        ...
        StylableImage("close")
          .resizable()
          .style("image")
        ...
      }
      ...
    }
```

In this case, the image would look for assets named `"client_searchbar_image"`, `"*_searchbar_image"`, `"client_*_image"` and finally `"*_*_image"`. This allows us to put a generic image called `"*_searchbar_image"` in an asset bundle, but also include an asset called `"client_searchbar_image"` to change the image only when the searchbar was in the client section of the app.

The call to `style(_:)` is so that we can add other styles to the image view via the stylist, and has no effect on the loaded image resource.

## Themes

Themes are modifiers that are applied to a stylist identifier to increase the specificity value when that theme is selected. To set a theme in your stylist, set it's `currentTheme` property:

```swift
let stylist = Stylist()
stylist.currentTheme = Theme(name: "dark")
```

Once a theme is set, any identifier registered with that stylist that is included in that theme will have a higher precedence than a non-themed identifier. For example, a stylist with the identifiers `a/b/c/d/token` and `@dark/token` registered, will give a higher precedence to the latter when compared with the identifier `a/b/c/d/token`.
