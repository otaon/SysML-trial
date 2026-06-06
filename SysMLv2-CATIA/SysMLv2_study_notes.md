# SysML v2 学習まとめ

---

## 1. SysML v2 概要

SysML v2はOMG（Object Management Group）が策定したシステムモデリング言語の次世代版。

| 観点 | SysML v1 | SysML v2 |
|---|---|---|
| 表記法 | グラフィカルのみ（UMLベース） | **テキスト記法が主** ＋ グラフィカル |
| 言語基盤 | UML プロファイル | 独自メタモデル（KerML基盤） |
| 中核概念 | Block, Port など | **Definition / Usage** |
| ツール連携 | ツール依存 | 標準API（SysML v2 API）で相互運用 |

---

## 2. Jupyter Notebook 導入手順（Windows）

SysML v2のテキスト記法を試せるJupyter環境の導入方法。

### 前提条件

- **Java**（バージョン21以上推奨）がインストール済みであること
  - 確認方法：コマンドプロンプトで `java -version`
- **Miniconda**（Python 3.x）がインストール済みであること
  - インストール時に「Add Anaconda to my PATH environment variable」を有効化すること
  - 確認方法：`conda --version`

### インストール手順

1. [SysML-v2-Release](https://github.com/Systems-Modeling/SysML-v2-Release) からリポジトリをダウンロードして解凍する
2. `install/jupyter/` フォルダ内の `install.bat` を実行する
3. **「ToS（利用規約）」エラーが出た場合**は以下を実行してから再度 `install.bat` を実行する：
   ```bat
   conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
   conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
   conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/msys2
   ```
   > MinicondaでもAnaconda社のチャンネル（pkgs/main等）をデフォルトで参照するため、同じエラーが発生する。
   > 個人学習目的であれば同意して問題ない。

### 起動方法

```bat
cd <ノートブックを置きたいフォルダのパス>
jupyter lab
```

`<ノートブックを置きたいフォルダのパス>` は自分で決めた任意のフォルダでよい（例：`%USERPROFILE%\Desktop\sysmlv2`）。

### Jupyter環境でできること

| 機能 | 内容 |
|---|---|
| 構文チェック | テキスト記法の誤りを即座に検出 |
| 意味検証 | 型の不整合などセマンティクスエラーの検出 |
| 図の自動生成 | `%viz` コマンドでダイアグラムをレンダリング（白黒） |
| APIパブリッシュ | `%publish` でモデルを外部サーバーに送信して共有 |

> `%viz` の出力は白黒のみ。カラー表示が必要な場合は **Syside**（VS Code拡張）や **Tom Sawyer SysML v2 Viewer** を使う。

---

## 3. Definition と Usage

SysML v2の最重要概念。「型の定義」と「その使い方（コンテキスト）」を明確に分離する。

```
Definition ＝ 設計図・仕様書（再利用可能な「型」）
Usage      ＝ 設計図をどの文脈でどう使うか
```

### Definitionの種類

| キーワード | 用途 |
|---|---|
| `part def` | 物理的・論理的な構成要素の型 |
| `attribute def` | 属性の型 |
| `port def` | 接続口の型 |
| `action def` | 振る舞いの型 |

### Usageの種類

| キーワード | 用途 |
|---|---|
| `part` | 構成要素の使用（所有関係） |
| `attribute` | 属性の使用 |
| `port` | 接続口の使用 |
| `action` | 振る舞いの使用 |

---

## 4. 記号の使い分け

| 記号 | 名称 | 意味 | 使う場所 |
|---|---|---|---|
| `:` | 型付け（typing） | Usageの型を指定 | `part engine : Engine` |
| `:>` | 特殊化（specializes） | Definitionの継承 | `part def ElectricMotor :> Engine` |
| `:>` | サブセット化（subsets） | 属性がある概念の部分集合であることを宣言 | `attribute displacement :> volume` |
| `:>>` | 再定義（redefines） | 親のUsageメンバーを上書き | `:>> displacement = 2.0 [SI::litre]` |

> `:>` は文脈によって「特殊化」と「サブセット化」の2つの意味を持つ。
> - Definition に対して使う → **特殊化**
> - attribute に対して使う → **サブセット化**

### サブセット化とは

「AはBという概念の一種である」という意味的な関係を宣言するもの。型情報だけでなく「何を意味する値か」まで表現できる。

```sysml
// wheelDiameter は「長さという概念」のサブセット
// → 型(LengthValue)が自動的に付き、「長さの一種だ」という意味も持つ
attribute wheelDiameter :> length;
```

単なる型付け（`:`）との違い：

```sysml
attribute displacement : ISQSpaceTime::VolumeValue;  // 「型がVolumeValueである」だけ
attribute displacement :> ISQSpaceTime::volume;      // 「体積という概念の一種」という意味も持つ
```

---

## 5. redefines（`:>>`）の詳細

### 行の先頭に書くパターン

```sysml
part familyCar : Vehicle {
    :>> totalMass = 1450 [SI::kg];  // 親のtotalMassを値ありで再定義
}
```

### 行の途中に書くパターン

```sysml
part def ElectricVehicle :> Vehicle {
    part motorEngine : ElectricMotor :>> engine;  // engineをElectricMotor型で再定義
}
```

### 再定義と値の代入の違い

ソフトウェアの「代入」は「中身だけを変える」操作だが、SysML v2の `:>>` は「定義そのものを上書きする」操作。値だけでなく、型・多重度・制約も同時に変更できる。

```
ソフトウェアの代入 → 中身（値）を変える
SysML v2の :>>   → 型・多重度・制約・値、全て変えられる
                   （書かなかった項目は親の定義が引き継がれる）
```

> 「値だけ変える」のは `:>>` が持つ機能の一部に過ぎない。

### リスコフの置換原則との違い

SysML v2の `:>>` はリスコフの置換原則を前提としない。

| 観点 | ソフトウェア（OOP） | SysML v2 |
|---|---|---|
| 再定義の目的 | 振る舞いの変更 | 概念の特殊化・具体化 |
| 置換原則 | 原則として必要 | 不要 |
| 親子関係の意味 | 振る舞いの互換性 | 分類上の階層関係 |

SysMLは実行されるシステムではなく「現実世界の記述」であるため、再定義後に元の性質が失われても「より具体的な仕様を書いた」に過ぎない。

---

## 6. 標準ライブラリの使い方

### 主なインポートパッケージ

```sysml
private import ScalarValues::*;       // String, Real, Integer など
private import ISQ::*;                // mass, power など物理量のusage
private import ISQMechanics::*;       // pressure, volumeFlowRate など
private import ISQElectromagnetism::*;// energy など
private import ISQSpaceTime::*;       // volume, length など
private import SI::*;                 // kg, litre, kilowatt など単位
```

### 注意点：SI単位ライブラリに存在しない単位

以下はSI標準ライブラリに含まれていないため、SI基本単位で換算して使う：

| 使いたい単位 | 代替 | 換算例 |
|---|---|---|
| inch | `SI::mm` | 17インチ → `430 [SI::mm]` |
| kPa | `SI::Pa` | 230kPa → `230000 [SI::Pa]` |
| kWh | `SI::J` | 100kWh → `360000000 [SI::J]` |

---

## 7. 実践例：自動車システムのモデル

```sysml
package AutomotiveSystem {
    private import ScalarValues::*;
    private import ISQ::*;
    private import ISQMechanics::*;
    private import ISQElectromagnetism::*;
    private import ISQSpaceTime::*;
    private import SI::*;

    // attribute def：属性の型
    attribute def FuelType {
        attribute name : String;
    }

    // part def：部品の型（設計図）
    part def Engine {
        attribute displacement :> volume;       // subset :>
        attribute maxPower     :> power;        // subset :>
        port exhaustPort       : ExhaustPort;
    }

    // specializes :>（Engineを特殊化）
    part def ElectricMotor :> Engine {
        attribute batteryCapacity :> energy;
        attribute zeroDisplacement :>> displacement = 0 [SI::litre];  // redefines :>>（行の途中）
    }

    part def Wheel {
        attribute wheelDiameter :> length;
        attribute tirePressure  :> pressure;
    }

    part def Vehicle {
        attribute totalMass :> mass;
        attribute fuelType  : FuelType;
        part engine  : Engine;
        part wheels  : Wheel[4];
        port fuelPort : FuelPort;
    }

    // specializes :>（Vehicleを特殊化）
    part def ElectricVehicle :> Vehicle {
        part motorEngine : ElectricMotor :>> engine;  // redefines :>>（行の途中）
    }

    port def FuelPort {
        attribute flowRate :> volumeFlowRate;
    }

    port def ExhaustPort {
        attribute exhaustTemp :> temperature;
    }

    // トップレベルのpart usage
    part familyCar : Vehicle {
        :>> totalMass = 1450 [SI::kg];           // redefines :>>（行の先頭）
        part :>> engine : Engine {
            :>> displacement = 2.0 [SI::litre];
            :>> maxPower     = 115 [SI::kilowatt];
        }
        part :>> wheels : Wheel {                // 多重度[4]は親から継承される
            :>> wheelDiameter = 430  [SI::mm];
            :>> tirePressure  = 230000 [SI::Pa];
        }
    }

    part electricSportsCar : ElectricVehicle {
        :>> totalMass = 2100 [SI::kg];
        part sportMotor : ElectricMotor :>> motorEngine {  // redefines :>>（行の途中）
            :>> batteryCapacity = 360000000 [SI::J];
            :>> maxPower        = 450 [SI::kilowatt];
        }
        part :>> wheels : Wheel {
            :>> wheelDiameter = 533  [SI::mm];
            :>> tirePressure  = 250000 [SI::Pa];
        }
    }
}
```

---

## 8. よくあるエラーと対処法

| エラー | 原因 | 対処 |
|---|---|---|
| `Couldn't resolve reference to Type 'String'` | `ScalarValues` 未インポート | `private import ScalarValues::*;` を追加 |
| `Couldn't resolve reference to Feature 'ISQElectricity::...'` | パッケージ名が誤り | 正しいパッケージ名（`ISQElectromagnetism`など）を確認 |
| `Couldn't resolve reference to Element 'SI::inch'` | SIライブラリに存在しない単位 | SI基本単位（`SI::mm`など）に換算して使う |
| `Duplicate of inherited member name` | 継承済みのメンバーを `:` で再定義しようとしている | `:>>` を使う |
| `Bound features should have conforming types` | 値の型と属性の型が一致しない | 単位付きで値を指定する（例：`2.0 [SI::litre]`） |

---

## 9. 参考リソース

| リソース | URL |
|---|---|
| SysML v2 Release（公式GitHub） | https://github.com/Systems-Modeling/SysML-v2-Release |
| オンラインJupyter環境 | https://www.sysmlv2lab.com |
| Syside（VS Code拡張、カラー図対応） | https://www.syside.io |
| Tom Sawyer SysML v2 Viewer | https://www.tomsawyer.com/sysml-v2-viewer |
