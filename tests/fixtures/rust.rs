use std::collections::HashMap;

use rand::{thread_rng, Rng};
use strum::IntoEnumIterator;
use strum_macros::{Display, EnumIter};
use serde::{Serialize, Deserialize};

// Map of neuron id -> ..
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NeuralNet {
    pub input_neurons: HashMap<usize, (InputNeuronType, InputNeuron)>,
    pub inner_neurons: HashMap<usize, InnerNeuron>,
    pub output_neurons: HashMap<usize, (OutputNeuronType, OutputNeuron)>,

    /// A mapping of neuron id -> neuron type, useful if you have a neuron id and want to find out
    /// what type of neuron it is.
    neuron_type_map: HashMap<usize, NeuronType>,
}

/// The brain of a lifeform. Has three neuron types: Input, Inner, and Output. Input has
/// information from the world, Inner creates a recursive structure, and Output creates actions the
/// lifeform takes on the world.
impl NeuralNet {
    pub fn new(num_inner_neurons: usize) -> Self {
        let mut input_neurons = HashMap::new();
        let mut output_neurons = HashMap::new();
        let mut inner_neurons = HashMap::new();
        let mut neuron_type_map = HashMap::new();

        // -- Generate Neurons

        for (idx, neuron_member) in InputNeuronType::iter().enumerate() {
            // Assuming there'll never be more than 100 input neuron types, we'll do this
            // to assure a different id from the other neurons
            let id = idx + 100;
            let neuron = InputNeuron { id, value: 0.0 };
            input_neurons.insert(id, (neuron_member, neuron));
            neuron_type_map.insert(id, NeuronType::InputNeuron);
        }

        // Note: If the 200 here changes, it needs to be changed in add_inner_neuron as well
        for idx in 0..num_inner_neurons {
            let id = idx + 200;
            let neuron = InnerNeuron { id };
            inner_neurons.insert(id, neuron);
            neuron_type_map.insert(id, NeuronType::InnerNeuron);
        }

        for (idx, neuron_member) in OutputNeuronType::iter().enumerate() {
            let id = idx + 300;
            let neuron = OutputNeuron { id };
            output_neurons.insert(id, (neuron_member, neuron));
            neuron_type_map.insert(id, NeuronType::OutputNeuron);
        }

        // -- Generate Neuron Ids

        Self {
            input_neurons,
            output_neurons,
            inner_neurons,
            neuron_type_map,
        }
    }

    /// Returns a neuron id randomly chosen from input neurons unioned with inner neurons.
    /// This is all the places where a gene can start from.
    /// Takes an optional "not" value, which, if supplied, will prevent this from returning
    /// that value.
    pub fn random_from_neuron(&self, not_id: Option<usize>) -> usize {
        let num_neurons = self.input_neurons.len() + self.inner_neurons.len();
        let idx = thread_rng().gen_range(0..num_neurons);

        let id: usize;

        if idx < self.input_neurons.len() {
            let ids = &self.input_neurons.keys().map(|k| *k).collect();
            id = get_id_not_id(ids, idx, not_id);
        } else {
            let ids = &self.inner_neurons.keys().map(|k| *k).collect();
            let index = idx - self.input_neurons.len();
            id = get_id_not_id(ids, index, not_id);
        }

        id
    }

    /// Returns a neuron id randomly chosen from inner neurons unioned with output neurons.
    /// This is all the places where a gene can end, aka go to.
    /// Takes an optional "not" value, which, if supplied, will prevent this from returning
    /// that value.
    pub fn random_to_neuron(&self, not_id: Option<usize>) -> usize {
        let num_neurons = self.inner_neurons.len() + self.output_neurons.len();
        let idx = thread_rng().gen_range(0..num_neurons);

        let id: usize;

        if idx < self.inner_neurons.len() {
            let ids = &self.inner_neurons.keys().map(|k| *k).collect();
            id = get_id_not_id(ids, idx, not_id);
        } else {
            let ids = &self.output_neurons.keys().map(|k| *k).collect();
            let index = idx - self.inner_neurons.len();
            id = get_id_not_id(ids, index, not_id);
        }

        id
    }

    pub fn neuron_type(&self, neuron_id: &usize) -> &NeuronType {
        &self.neuron_type_map[neuron_id]
    }

    /// Add an inner neuron after the net is initially created. Initially made for mutation
    pub fn add_inner_neuron(&mut self) {

        let id;

        if self.inner_neurons.len() == 0 {
            id = 200;
        } else {
            id = self.inner_neurons.keys().max().unwrap() + &1;
        }

        self.inner_neurons.insert(id, InnerNeuron { id });
        self.neuron_type_map.insert(id, NeuronType::InnerNeuron);
    }

    /// Remove an inner neuron after the net is initially created. Initially made for mutation
    pub fn remove_inner_neuron(&mut self, id: usize) {
        self.inner_neurons.remove(&id);
        self.neuron_type_map.remove(&id);
    }
}

#[derive(Debug, EnumIter, Clone, Display, Serialize, Deserialize)]
pub enum InputNeuronType {
    VisionDistanceLeft,
    VisionTypeLeft,
    VisionDistanceCenter,
    VisionTypeCenter,
    VisionDistanceRight,
    VisionTypeRight,
    PharamoneRedLeft,
    PharamoneRedRight,
    PharamoneYellowRight,
    PharamoneYellowLeft,
    PharamoneBlueRight,
    PharamoneBlueLeft,
    Health,
    Hunger,
    PopulationDensity,
    NeighborhoodDensity,
    Random,
    Oscillator,
}

#[derive(Debug, Default, Clone, Serialize, Deserialize)]
pub struct InputNeuron {
    pub id: usize,
    pub value: f32,
}

#[derive(Debug, EnumIter, Clone, Display, Serialize, Deserialize)]
pub enum OutputNeuronType {
    TurnLeft,
    TurnRight,
    MoveForward,
    Attack,
    ExcretePharamoneRed,
    ExcretePharamoneYellow,
    ExcretePharamoneBlue,
}

#[derive(Debug, Default, Clone, Serialize, Deserialize)]
pub struct OutputNeuron {
    pub id: usize,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InnerNeuron {
    pub id: usize,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum NeuronType {
    InputNeuron,
    InnerNeuron,
    OutputNeuron,
}

/// The basic issue is that we want to request a random neuron id, but we sometimes want
/// to make sure that it's different from a given one, which in this case is called not_id.
/// This is just a helper to abstract some of the repeated logic in random_{from,to}_neuron.
fn get_id_not_id(ids: &Vec<usize>, mut idx: usize, not_id: Option<usize>) -> usize {
    let mut id = ids[idx];

    if let Some(not_id) = not_id {
        if not_id == id {
            if idx > 0 {
                idx -= 1;
            } else {
                idx += 1;
            }
        }
    }

    // On some occasions we may have a length one vector.
    // In these cases, we'll just return the first id.
    if idx >= ids.len() {
        idx = 0;
    }

    id = ids[idx];

    id
}

#[cfg(test)]
mod test {

    use super::*;

    #[test]
    fn add_inner_neuron() {
        let mut nn = NeuralNet::new(0);
        assert_eq!(nn.inner_neurons.len(), 0);
        nn.add_inner_neuron();
        assert_eq!(nn.inner_neurons.len(), 1);
    }

    #[test]
    fn remove_inner_neuron() {
        let mut nn = NeuralNet::new(1);

        assert_eq!(nn.inner_neurons.len(), 1);

        let id = nn.inner_neurons.keys().last().unwrap();
        nn.remove_inner_neuron(*id);

        assert_eq!(nn.inner_neurons.len(), 0);
    }
}

