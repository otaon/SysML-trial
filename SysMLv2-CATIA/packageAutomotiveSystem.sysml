package AutomotiveSystem {
    private import ScalarValues::*;
    private import ISQ::*;
    private import ISQMechanics::*;
    private import ISQElectromagnetism::*;
    private import ISQSpaceTime::*;
    private import SI::*;
    attribute def FuelType {
        attribute name : String;
    }

    // 【エンジン】型の定義
    part def Engine {
        /*
         * 属性
        */
        // 【_排気量】：【_容量】の部分集合として定義する。
        attribute displacement :> volume;
        // 【_最大馬力】：【_馬力】の部分集合として定義する。
        attribute maxPower :> power;

        /*
         * ポート
        */
        // 【_排気ポート】：【排気ポート】型のポートを定義する。
        port exhaustPort : ExhaustPort;
    }

    // 【電動モーター】型の定義：【エンジン】型の部分集合として定義する。
    part def ElectricMotor :> Engine {
        /*
         * 属性
        */
        // 【_バッテリー容量】：【_エネルギー】の部分集合として定義する。
        attribute batteryCapacity :> energy;
        // 【_ゼロ排気量】：【_排気量】を、【_ゼロ排気量】(値は0[L])として再定義する。
        attribute zeroDisplacement :>> displacement = 0 [SI::litre];
    }

    // 【ホイール】型の定義
    part def Wheel {
        /*
         * 属性
        */
        // 【_ホイール直径】：【_長さ】の部分集合として定義する。
        attribute wheelDiameter :> length;
        // 【_タイヤ空気圧】：【_圧力】の部分集合として定義する。
        attribute tirePressure :> pressure;
    }

    // 【自動車】型の定義
    part def Vehicle {
        /*
         * 属性
        */
        // 【_総重量】：【_質量】の部分集合として定義する。
        attribute totalMass :> mass;
        // 【_燃料タイプ】：【燃料タイプ】型の属性を定義する。
        attribute fuelType : FuelType;

        /*
         * パート
        */
        // 【_エンジン】：【エンジン】型のパートを所有する。
        part engine : Engine;
        // 【_ホイール】：【ホイール】型パートを4個所有する。
        part wheels : Wheel [4];

        /*
         * ポート
        */
        // 【_燃料ポート】：【燃料ポート】型のポートを所有する。
        port fuelPort : FuelPort;
    }

    // 【電気自動車】型の定義：【自動車】型の部分集合として定義する。
    part def ElectricVehicle :> Vehicle {
        /*
         * ポート
        */
        // 【_モーターエンジン】：【_エンジン】を、【電動モーター】型の【_モーターエンジン】として再定義する。
        part motorEngine : ElectricMotor :>> engine;
    }

    // 【燃料ポート】型の定義
    port def FuelPort {
        /*
         * 属性
        */
        // 【_流量】：【_体積流量】の部分集合として定義する。
        attribute flowRate :> volumeFlowRate;
    }

    // 【排気管】型の定義
    port def ExhaustPort {
        /*
         * 属性
        */
        // 【_排気温度】：【_温度】の部分集合として定義する。
        attribute exhaustTemp :> temperature;
    }

    // 【ファミリーカー】：【自動車】型として作る。
    part familyCar : Vehicle {
        /*
         * 属性
        */
        // 【_総重量】を値ありに再定義する。
        :>> totalMass = 1450 [SI::kg];

        /*
         * パート
        */
        // 【_エンジン】：【_エンジン】を再定義する。
        part :>> engine : Engine {
            /*
             * 属性
            */
            // 【_排気量】を値ありに再定義する。
            :>> displacement = 2.0 [SI::litre];
            // 【_最大馬力】を値ありに再定義する。
            :>> maxPower = 115 [SI::kilowatt];
        }
        // 【_ホイール】：【_ホイール】を再定義する。
        part :>> wheels : Wheel {
            /*
             * 属性
            */
            // 【_ホイール直径】を値ありに再定義する。
            :>> wheelDiameter = 430 [SI::mm];
            // 【_タイヤ空気圧】を値ありに再定義する。
            :>> tirePressure = 230000 [SI::Pa];
        }
    }

    // 【電動スポーツカー】：【電動自動車】型として作る。
    part electricSportsCar : ElectricVehicle {
        /*
         * 属性
        */
        // 【_総重量】を値ありに再定義する。
        :>> totalMass = 2100 [SI::kg];

        /*
         * パート
        */
        // 【_スポーツモーター】：【_モーターエンジン】を【電動モーター】型の【_スポーツモーター】として再定義する。
        part sportMotor : ElectricMotor :>> motorEngine {
            // 【_バッテリー容量】を値ありに再定義する。
            :>> batteryCapacity = 360000000 [SI::J];
            // 【_最大馬力】を値ありに再定義する。
            :>> maxPower = 450 [SI::kilowatt];
        }
        // 【_ホイール】：【_ホイール】を再定義する。
        part :>> wheels : Wheel {
            /*
             * 属性
            */
            // 【_ホイール直径】を値ありに再定義する。
            :>> wheelDiameter = 533 [SI::mm];
            // 【_タイヤ空気圧】を値ありに再定義する。
            :>> tirePressure = 250000 [SI::Pa];
        }
    }

    view AutomotiveSystem : DS_Views::SymbolicViews::gv;

    comment 
    /* part defは、ブループリント(設計書)そのもの。
     * 下記の記載は、「「Cockpitを持ったF1」を作るための設計書」と捉えるべき。
     *
     * ```
     * part def F1 :Car {
     *     part Cockpit: Chair;
     * }
     * ```
     * 下記の記載は、「「Cockpitの設計書を持ったF1」を作るための設計書」と捉えるべき。
     * F1に乗ろうとしたら、座るべき場所にはCockpitの設計書がポツンと置いてあるイメージ。
     * ```
     * part def F1 :Car {
     *     part def Cockpit: Chair;
     * }
     * ```*/
    comment 
    /* 赤い太字…partの再定義
     * 赤い細字…attributeの再定義*/
}
