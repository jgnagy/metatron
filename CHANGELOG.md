# Changelog

## [0.11.0](https://github.com/jgnagy/metatron/compare/metatron/v0.10.1...metatron/v0.11.0) (2025-03-28)


### ⚠ BREAKING CHANGES

* **templates:** secret now base64 encodes
* **templates:** omit attribute when default

### Code Refactoring

* **templates:** omit attribute when default ([0add60c](https://github.com/jgnagy/metatron/commit/0add60c5ef9faca5e1c7be050415ef3a1f15227b))
* **templates:** secret now base64 encodes ([3d263ec](https://github.com/jgnagy/metatron/commit/3d263ec85b9d7e87b987c2fcf4c6fc9664eb84d6))

## [0.10.1](https://github.com/jgnagy/metatron/compare/metatron/v0.10.0...metatron/v0.10.1) (2025-03-21)


### Features

* **misc:** allow ping controller usage as class ([60048f3](https://github.com/jgnagy/metatron/commit/60048f3905959bf4193254e9e3f3800298cbc494))

## [0.10.0](https://github.com/jgnagy/metatron/compare/metatron/v0.9.0...metatron/v0.10.0) (2025-03-19)


### ⚠ BREAKING CHANGES

* **templates:** pod match labels are distinct
* **templates:** allow overriding base labels

### Features

* **templates:** allow overriding base labels ([ba3d4c2](https://github.com/jgnagy/metatron/commit/ba3d4c2813518a5b9bb845700656b2ce67321369))
* **templates:** pod match labels are distinct ([82b59d0](https://github.com/jgnagy/metatron/commit/82b59d0d93cbf1c4423895f20351e2b73d6057e0))

## [0.9.0](https://github.com/jgnagy/metatron/compare/metatron-v0.8.8...metatron/v0.9.0) (2025-02-17)


### Features

* **templates:** add priority class template ([a735e47](https://github.com/jgnagy/metatron/commit/a735e470d0a2f5c7c471ec95a7559cbbe8349268))
* **templates:** add support for pod priority ([f73d7b2](https://github.com/jgnagy/metatron/commit/f73d7b293c26eb0b5e2f65212c87a32b701b2151))

## [0.8.8](https://github.com/jgnagy/metatron/compare/v0.8.2...v0.8.8) (2025-02-16)


### Features

* adding support for LimitRange resource ([b779d47](https://github.com/jgnagy/metatron/commit/b779d4764ccf5b0e687ff328e69808ae12ff3c30))
* adds dataSource and dataSourceRef to PVCs ([5339a4e](https://github.com/jgnagy/metatron/commit/5339a4ea732695530814e281f6d0ae2de3e7889d))
