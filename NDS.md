# Natural Design System (NDS)
Creating applications does not necessarily mean creating complex processes. We're building tools to enable you to go from design to productions as effortlessly possible.

## The system
Swapping out library files is a fairly ubiquitous task, and there are plenty of plugins that can do this for you. But we're not just swapping out one library for another. We're creating a system that empowers you to create any number of libraries based on a simple Component & Token structure, interchange them with each other and ultimately hand them over to dev for quick implementation.

### Workflow

##### 💎 Layout & Components ↔︎ 💎 Token File ⇾ ⚙️ Convertor ⇾ ⚙️ Stylist in Product



## Components & Tokens

### Components

Everything from applications to websites are created based on Components. Components are the building blocks of everything. Examples of commonly used components are:

* Header
* Footer
* Buttons
* Search Bar

### Tokens

At the micro level, components are made up of Tokens. Tokens are the smallest and undividable building blocks of our designs. Tokens carry all the information we need to style our applications eg. Text Styles, Layer Styles and Icons. Examples of commonly used Tokens are:

* Title (text style)
* Subtitle (text style)
* Label (text style)
* Background (layer style)
* Search Icon (icon)
* Arrow Icon (icon)

## Nesting and building

Components can be nested, thus creating even more complex systems within our designs. An example of a nested component path would be: `home/header/searchBar/label`

![Breakdown](https://f000.backblazeb2.com/file/LovelyDropshare/sWO41CjF/breakdown.png)

## Hierarchy
Given the above structure `home/header/searchBar/label`, the matching hierarchy is as follows:

1. `home/header/searchBar/label`
2. `header/searchBar/label`
3. `home/searchBar/label`
4. `home/header/label`
5. `searchBar/label`
6. `header/label`
7. `home/label`
8. `label`

## Component Variants
Similar to states, **Variants** can be used to describe a specific state of a **Component** but they can also be used to specifiy a variant of that **Component** as well. Variants are specified by appending the variant name enclosed in brackets to the Component name.

#### Example for Style Variants
* `_button`
* `_button[active]`
* `_button[disabled]`

#### Example for Layout Variants
* `carousel`
* `carousel[fullWidth]`
* `carousel[paged]`

## Modifiers
Modifiers are extra properties that are applied to Tokens, which are not included in Sketch's Text Style or Layer Style. Currently, we only support the Radius (` --radius`) modifier.

#### Radius Modifier
If we need to apply a radius to a layer, we would use a radius modifier:

Create a new artboard named `tag/background --radius`, and in that artboard we would include a single layer with the required radius.

## Direct Inheritance [TBA]
If we need to specifically target a component's direct descendant, we can specifically declare the target by prepending a `>` in the Token name.

eg `card/>background` will only be applied to the `background` directly nested in `card` and will not be inherited by anything else eg. `card/tag/background`. 

## Glossary

*Token:* A token describes the smallest and undividable parts of your design. Tokens are **Text Styles**, **Layer Styles** or **Icons**.

*Component:* A component is made up of **Tokens** and nested **Components** and represents more complex structures in your designs.

*Variant:* Variants are used to describe a specific state or layout variant of a **Component**.

## Rules

1. **Components** must have unique names. 
2. **Components** must have an underscore (`_`) prepending their names.
3. Variants can only be applied to **Components**.
4. A default for each **Token** is required.

