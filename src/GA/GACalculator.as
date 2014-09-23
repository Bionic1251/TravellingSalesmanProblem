package GA {
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.utils.ObjectUtil;

	public class GACalculator {
		public var dotArray:ArrayList;
		public var population:ArrayCollection;
		private static const POPULATION_MUTATION_PART:Number = 0.6;
		private static const CREATURE_MUTATION_PART:Number = 0.4;
		private static const POPULATION_SIZE:int = 100;
		[Bindable]
		public static var populationMutationPart:Number = POPULATION_MUTATION_PART;
		[Bindable]
		public static var creatureMutationPart:Number = CREATURE_MUTATION_PART;
		[Bindable]
		public static var populationSize:int = POPULATION_SIZE;

		public function GACalculator(dotArray:ArrayList) {
			this.dotArray = dotArray;
			createPopulation();
			sortPopulationAsc();
		}

		public function generateNewPopulation():void {
			crossoverPopulation();
			mutation();
			sortPopulationAsc();
		}

		public function findTheBestWay():void {
			while (!isChangedPopulationMutationPartOnly()) {
				generateNewPopulation();
				sortPopulationAsc();
			}
		}

		private function isChangedPopulationMutationPartOnly():Boolean {
			var mainFitness:int = fitness(population.getItemAt(0) as Array);
			var quantity:int = 0;
			for each (var creature:Array in population) {
				if (mainFitness == fitness(creature)) {
					quantity++;
				}
			}
			//trace(quantity + " " + ((1 - populationMutationPart) * populationSize - 1));
			if (quantity >= (1 - populationMutationPart) * populationSize - 1) {
				return true;
			} else {
				return false;
			}
		}

		private function crossoverPopulation():void {
			var creature1:Array;
			var creature2:Array;
			for (var i:int = population.length / 2; i < population.length; i++) {
				creature1 = population.getItemAt(Math.random() * population.length / 2) as Array;
				creature2 = population.getItemAt(Math.random() * population.length / 2) as Array;
				population.setItemAt(crossover(creature1, creature2), i);
			}
		}

		private function crossover(creature1:Array, creature2:Array):Array {
			var child:Array = new Array();
			for (var i:int = 0; i < creature1.length / 2; i++) {
				child.push(creature1[i]);
			}
			for (i = 0; i < creature2.length; i++) {
				if (!isIncludeElement(child, creature2[i])) {
					child.push(creature2[i]);
				}
			}
			return child;
		}

		private function isIncludeElement(array:Array, element:Object):Boolean {
			for each (var curElement:Object in array) {
				if (curElement == element) {
					return true;
				}
			}
			return false;
		}

		private function createPopulation():void {
			population = new ArrayCollection();
			for (var i:int = 0; i < populationSize; i++) {
				population.addItem(getNewCreature());
			}
		}

		private function getNewCreature():Array {
			var dotArray:Array = copyDotArray(this.dotArray.source);
			var index1:int;
			var index2:int;
			for (var i:int = 0; i < dotArray.length; i++) {
				index1 = int(Math.random() * dotArray.length);
				index2 = int(Math.random() * dotArray.length);
				swapElements(dotArray, index1, index2);
			}
			return dotArray;
		}

		private function swapElements(dotArray:Array, index1:int,
				index2:int):void {
			var dot:Object = dotArray[index1];
			dotArray[index1] = dotArray[index2];
			dotArray[index2] = dot;
		}

		private function copyDotArray(dotArray:Array):Array {
			var array:Array = new Array();
			for each (var dot:Dot in dotArray) {
				array.push(dot);
			}
			return array;
		}

		public static function fitness(creature:Array):int {
			var distance:int = 0;
			for (var i:int = 0; i < creature.length - 1; i++) {
				distance += getDistance(creature[i], creature[i + 1]);
			}
			distance += getDistance(creature[0], creature[creature.length - 1]);
			return distance;
		}

		private function mutation():void {
			var maxFitness:int = getMaxFitness();
			var mutationCount:int = 0;
			for each (var creature:Array in population) {
				if (Math.random() < fitness(creature) / maxFitness ||
						Math.random() < 0.1) {
					mutationCount++;
					mutateCreature(creature);
				}
				if (mutationCount / population.length >= populationMutationPart) {
					break;
				}
			}
		}

		private function mutateCreature(dotArray:Array):void {
			var index1:int;
			var index2:int;
			for (var i:int = 0; i < dotArray.length * creatureMutationPart; i++) {
				index1 = int(Math.random() * dotArray.length);
				index2 = int(Math.random() * dotArray.length);
				swapElements(dotArray, index1, index2);
			}
		}

		private function getMaxFitness():int {
			sortPopulationDesc();
			return fitness(population.getItemAt(population.source.length - 1) as Array);
		}

		private static function getDistance(dot1:Dot, dot2:Dot):int {
			var line:Line = getLineByDots(dot1, dot2);
			if (line == null) {
				return int.MAX_VALUE;
			} else {
				return parseInt(line.text);
			}
		}

		public static function getLineByDots(dot1:Dot, dot2:Dot):Line {
			var lineArray:Array = dot1.lineArray;
			for each (var line:Line in lineArray) {
				if (line.isDotUsed(dot2)) {
					return line;
				}
			}
			return null;
		}

		private function sortPopulationDesc():void {
			sortPopulation(compareFunctionReverse);
		}

		private function sortPopulationAsc():void {
			sortPopulation(compareFunction);
		}

		private function sortPopulation(compareFunction:Function):void {
			var sort:Sort = new Sort();
			sort.compareFunction = compareFunction;
			population.sort = sort;
			population.refresh();
		}

		private function compareFunction(creature1:Array, creature2:Array,
				fields:Array = null):int {
			var fitness1:int = fitness(creature1);
			var fitness2:int = fitness(creature2);
			return ObjectUtil.numericCompare(fitness1, fitness2);
		}

		private function compareFunctionReverse(creature1:Array,
				creature2:Array, fields:Array = null):int {
			var fitness1:int = fitness(creature1);
			var fitness2:int = fitness(creature2);
			return ObjectUtil.numericCompare(fitness2, fitness1);
		}
	}
}